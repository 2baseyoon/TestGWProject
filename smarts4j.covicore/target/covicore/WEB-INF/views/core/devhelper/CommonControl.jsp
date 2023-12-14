<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>

<style>
/* Commoncontrol.jsp 개별 CSS  */
.section_title{
	font: normal 18px '맑은 고딕', Malgun Gothic,Apple-Gothic,dotum,돋움,sans-serif;
    color: #222;
    line-height: 20px;
    padding-left: 20px;
    background: url(/HtmlSite/smarts4j_n/covicore/resources/images/covision/zadmin/ico_collection.gif) no-repeat 0 -92px;
}

.AXFormTable td, .AXFormTable td{
	line-height: 22px;
}

/* 컨트롤에 필요한 공통 CSS 내용  */
.mt5 {margin-top:5px !important;}
.mt10 {margin-top:10px !important;}
.mt15 {margin-top:15px !important;}
.mt65 {margin-top:65px !important;}
.mb5 {margin-bottom:5px !important;}
.mb10 {margin-bottom:10px !important;}

.btnTypeDefault {
    border: 1px solid #d6d6d6;
    padding: 0 9px 0;
    display: inline-block;
    min-width: 60px;
    text-align: center;
    height: 30px;
    line-height: 28px;
    font-size: 13px;
    font-family: 맑은 고딕, Malgun Gothic,sans-serif, dotum,'돋움',Apple-Gothic;
    border-radius: 2px;
    transition: box-shadow .3s;
    background-color: #fff;
}

.addDataBtn+div {
    border: 1px solid #d6d6d6 !important;
    border-radius: 2px !important;
}

.subTitle {
	font-size: 15px;
    margin-top: 7px;
    margin-left: 10px;
    color: #565b61;
}

.dateSel {line-height:28px;}
.dateSel {font-size:14px;}
.dateSel input {color: #717b85 !important; border: 1px solid #c6c6c6 !important;}
.dateSel span[name='date'] input {height: 22px; }
.dateSel span[name='datePicker'] {margin-right:5px;}
.dateSel span[name='datePicker'] select {width:60px;background-position:40px center;}
.dateSel span[name='startDate'] img {margin-bottom: 3px;}
.dateSel span[name='startDate'] input {height: 22px; margin-bottom: 3px;  padding-left: 2px;}
.dateSel span[name='startDate'] select {margin-left:5px;}
.dateSel span[name='startDate'] select:first-child {margin-left:0;}
.dateSel span[name='startHour'] select {margin:0 5px;width:40px;background-position:22px center;}
.dateSel span[name='startMinute'] select {/*margin-right:5px;*/width:40px;background-position:22px center;}
.dateSel span[name='endDate'] img {margin-bottom: 3px;}
.dateSel span[name='endDate'] input {height: 22px; margin-bottom: 3px;  padding-left: 2px;}
.dateSel span[name='endHour'] select {margin:0 5px;width:40px;background-position:22px center;}
.dateSel span[name='endMinute'] select {/*margin-right:5px;*/width:40px;background-position:22px center;}

.flowerPopup {}
.flowerPopup > a {display:block;width:100%;height:38px;line-height:38px;color:#9a9a9a !important;}
.flowerMenuList.active {display:block;}
.flowerMenuList:after, .flowerMenuList:before {border: solid transparent; content:" ";	height:0; width:0; position:absolute; top:-11px; left:50%; margin-left:-5px; pointer-events: none;z-index:1;}
.flowerMenuList:after {top:-10px;border-color: rgba(255, 255, 255, 0);border-bottom-color: #fff;border-width: 5px;}
.flowerMenuList {position:absolute;left:70%;margin:-3px 0 0 -67px;display:none;width:134px;background:#fff;border-radius:2px;z-index:5;}
.flowerMenuList:before {border-width: 5px;}
.flowerMenuList > li {height:40px;line-height:39px;border-top:1px solid #f4f4f4;}
.flowerMenuList > li:first-child {border:none;}
.flowerMenuList > li > a {position:relative;padding-left:40px;display:block;width:100%;height:100%;font-size:13px;text-align:left;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.flowerMenuList > li > a:after {content:'';position:absolute;top:12px;left:14px;display:block;}
.flowerMenuList .flowerProfile > a:after {width:19px;height:20px;}
.flowerMenuList .flowerMail > a:after {width:18px;height:15px;background-position:0 -40px;}
.flowerMenuList .flowerFollowing > a:after {width:15px;height:15px;background-position:0 -75px;}
.flowerMenuList .flowerTalk > a:after {width:18px;height:18px;background-position:0 -110px;}
.flowerMenuList .flowerAddr > a:after {width:17px;height:19px;background-position:0 -148px;}

.flowerMenuList {border:1px solid #364d5d;}
.flowerMenuList:before {
	border-color: rgba(54, 77, 93, 0);
	border-bottom-color: #364d5d;
}
.flowerMenuList > li > a {color:#364d5d;}

.autoCompleteCustom {font-size:0;}
.autoCompleteCustom.place .ui-autocomplete-multiselect input {margin:0 2px;min-height:27px;}
.autoCompleteCustom.place .ui-autocomplete-multiselect.ui-state-default {padding:0;}
.autoCompleteCustom.place .ui-autocomplete-multiselect .ui-autocomplete-multiselect-item {margin-top:2px;}
.autoCompleteCustom .ui-autocomplete-multiselect.ui-state-default {padding:1px 2px 2px;display:inline-block;height:auto;border-radius:2px;width:100%;}
.autoCompleteCustom .ui-autocomplete-multiselect input {margin-bottom:0px;padding:0 6px;max-width:100% !important;width:auto !important;height:24px;line-height:24px;border:none;vertical-align:top;font-size:14px;}
.autoCompleteCustom .ui-autocomplete-multiselect .ui-autocomplete-multiselect-item {margin:1px 2px 0 0;padding:1px 3px; padding-right:20px; font-size:13px;border-radius:0;height:22px;line-height:20px;}
.autoCompleteCustom .ui-autocomplete-multiselect .ui-autocomplete-multiselect-item .ui-icon {position:absolute;top:50%;margin:-7px 0 0 6px;display:inline-block;width:8px;height:14px;background:url('/HtmlSite/smarts4j_n/covicore/resources/images/common/ic_bt_remove.png') no-repeat center center;text-indent:-9999px;}
.autoCompleteCustom .btnTypeDefault {vertical-align:top;}
.autoCompleteCustom .ui-autocomplete-multiselect.ui-state-default~.btnTypeDefault  {margin-left:5px;}
.autoCompleteCustom .ui-autocomplete-multiselect.ui-state-default {border:1px solid #d6d6d6;}
.autoCompleteCustom .ui-autocomplete-multiselect .ui-autocomplete-multiselect-item {position:relative;padding-right:20px;}

.palette-color-picker-bubble{z-index:1;}

.appBox *{box-sizing: border-box; -webkit-box-sizing: border-box;}
.appTree {float:left; width:211px; margin-right:10px; border:1px solid #d3d8df; padding:10px; /*height:459px;*/ height:475px; font-size: 13px; box-sizing: border-box;}
.appTree a {font-size: 13px;}
.appTreeTop {position:absolute; width:209px; height:40px;}
.appTreeBot {margin-top:42px; z-index:100; overflow:auto; height:415px;}
.appTree .treeBodyTable input {margin-right:4px; margin-left:-20px !important; border:0;}
.appLinebox {clear:both;}
.appList {float:left; width:276px; /*height:440px;*/ height: 435px; border-left:1px solid #d3d8df; border-right:1px solid #d3d8df; border-bottom:1px solid #d3d8df; overflow:auto;}
.appInfo {float:left; font-size: 13px; width:450px; height:233px; margin:0px 0 10px 0;  border:1px solid #d3d8df;}
.appInfo02 {float:left; width:450px; height:433px; margin:0px 0 10px 0; overflow:auto; border:1px solid #d3d8df;}
.appPers {float:right; width:209px; height:433px; /*margin:56px 0px 0 0;*/ margin:0px; border:1px solid #d3d8df; overflow-y:auto; overflow-x:hidden;}
.appInfoBot {float:left; width:450px; height:188px; overflow:auto; border:1px solid #d3d8df; margin-bottom:10px;}
.treeSelect {width:190px;}
.appListTop {position:absolute; width:274px !important; height:40px;}
.appListBot {margin-top:42px; width:100%; z-index:100; overflow:auto; height:449px;}
.appListBot td {height:50px !important;}
.appBtn {position:relative; float:left; width:109px; text-align:center; margin-top:110px;}
.appTab {float:left; width:452px;}
.popBtn {clear:both; width:100%; border-top:1px solid #b9c2cc; text-align:right; padding:15px 0px 15px 0px;}
.appBox {/*height:609px;*/ padding:10px; font-size: 13px; float: left; width: 100%;}
.AXTree_none .AXTreeScrollBody {border:none !important;}
.appTreeBot .AXTree_none .AXTreeScrollBody .AXTreeBody .treeBodyTable tbody tr td .bodyTdText {padding:0px 8px;}
.appBtnSend {float:left; width:109px; margin-top:176px; text-align:center;}
.appBtnSend02 {float:left; width:109px; margin-top:88px; text-align:center;}
.appTab {float:left; width:452px;}
.appOpen {position:absolute; right:0; top:50%; margin-top:-34px; width:20px; height:68px; display:block; background:url(/HtmlSite/smarts4j_n/covicore/resources/images/theme/blue/icn_png.png) no-repeat -430px -10px; text-indent:-20000px; z-index:105;}
.appClose {position:absolute; right:220px; top:50%; margin-top:-34px; width:20px; height:68px; display:block; background:url(/HtmlSite/smarts4j_n/covicore/resources/images/theme/blue/icn_png.png) no-repeat -460px -10px; text-indent:-20000px; z-index:105;}
.appTab .AXTabsLarge {margin-top:10px !important;}

.cirPro {border-radius:50%; width:40px; height:40px; left:50%; top:50%; overflow:hidden; display:inline-block; border:1px solid #dcdcdc;}
.cirPro img { width:100%;}
.t_center{text-align:center ! important;}

.appBox select {padding-left:3px;border:1px solid #c6c6c6; height:30px; border-radius:3px; color:#333; box-shadow:none !important;-webkit-appearance: none;-moz-appearance: none;appearance: none;padding-right: 15px; text-indent:3px;}
.appBox input {margin:0px;padding:0px 6px 0 0;height:30px;color:#000 !important;border: 1px solid #c6c6c6;border-radius:3px !important;box-shadow:none !important;text-indent:6px;}
.appList_top_b{margin-bottom: 10px;}

.AXanchorSelectorHandleContainer {display:none;}
.j_appSelect {width:80px;}
.searchImgBlue {background: url(/HtmlSite/smarts4j_n/covicore/resources/images/theme/blue/icn_png.png) no-repeat -10px -208px !important; }
.searchImgBlue {display:inline-block;line-height:18px;margin: 0 0 0 -24px;text-indent:-20000px;width:24px;height:20px;}

.taTit {font-size:13px;white-space:nowrap; overflow:hidden; line-height:22px; text-overflow:ellipsis; width:100%;}
.tableTxt {display:inline-block; height:20px; clear:both;}
.tableStyle .subject {text-align:left; line-height:19px !important; color:#222;}
.tableStyle .subject dl {margin:13px 0;line-height:19px;}
.tableStyle .subject dt {line-height:19px;}
.tableStyle .subject dd {line-height:19px;}
.tableStyle .subject .lGry {color:#888; margin:0px;}
.listinfo {display:block;}
.listinfo li:first-child {background:none; padding-left:0px;}
.listinfo li:last-child { }
.listinfo li {list-style:none; float:left; line-height:18px; padding-right:8px; padding-left:8px;  font-size:12px; color:#888;}
.tableStyle .listinfo li {float:left; padding:0 6px; color:#888;}
.tableStyle .listinfo li:first-child {padding-left:0;}
.tableStyle .listinfo li:last-child {background:none;}
.linePlus tr:first-child td, .linePlus tr:first-child th, .linePlus tr:last-child th  {border-top:1px solid #c3d7df;border-bottom:1px solid #c3d7df;}
.linePlus .edit_con_wrap table td, th {border:0px;}
.linePlus td,  .linePlus th {border-right:1px solid #c3d7df;}
.linePlus td:first-child, .linePlus th:first-child {border-left:1px solid #c3d7df;}
.tableStyle {width:100%;table-layout:fixed;word-break:break-all;}
.tableStyle thead {border-top:1px solid #d2d7de;}
.tableStyle.topline {border-top:0;}
.tableStyle thead th , .tableStyle tbody th  {height:40px;border-bottom:1px solid #d2d7de;font-size:13px;font-weight:bold;color:#000;background:#f1f6f9;}
.tableStyle thead td , .tableStyle tbody td {color:#000;border-bottom:1px solid #c3d7df;padding:5px;height:31px;position:relative;}
.tableStyle.hover tr:hover {background:#f7f7f7;	cursor:pointer;}
.tableStyle tr.openApp td {padding:10px !important;}
.openApp:hover td { background:none !important;}
.tableStyle.hover tbody tr:hover td a.subject {color:#e9002d;text-decoration:underline;cursor:pointer;border-bottom:1px solid #d2d7de;}
.tableStyle thead tr:last-child td , .tableStyle thead tr:last-child th {border-bottom:1px solid #eaecef;}
.help_ico.active:after { display:inline-block;  }
.helppopup { top:25px; left:0; min-width:200px; min-height:52px; background:#4A86E8; border-radius: 10px; color:#fff; padding:15px; font-size:13px; font-weight: 400; line-height: 22px; font-size:13px; z-index:99; }
#orgSearchListMessage{display:none;}

.fileList02 .WebHardList .body_type { position:absolute; top:0 !important; left:0 !important; margin:-5px 0 0 -7px; display:inline-block; width:125px !important; height:25px !important; padding:4px 0 0 10px !important; background:url('/HtmlSite/smarts4j_n/collaboration/resources/images/bg_bodytype.png') no-repeat left top !important; color:#fff !important; font-size:12px !important; font-weight:bold !important; }
.Project_filter.tag { background:none; }
#dttab-3.list-fluid .column.active { min-width:100%; max-width:100%; width:100%; }
.cal_chk.milestone { position:absolute; top:2px; left:10px; }
.card_chk.milestone { position:absolute; }
.list_chk.milestone { width:25px; }
.coWorkBox .user_img { left:30px; }
.coWorkBox { padding:0 73px 0 58px; }
.helppopup_tit { display:block; padding-bottom:5px; margin-bottom:5px; font-weight:bold; font-size:14px; }
.helppopup span.tx_ex { display:inline-block; margin:0; padding:0 6px; height:20px; line-height:18px; background-color:#70a5fb; border-radius:2px; color:#fff; font-size:11px; vertical-align:top; margin:1px 5px 0 0; }
.collabo_help02 { display:inline-block; }
.collabo_help02 a.help_ico { position:relative; display: inline-block; width:16px; height:16px; background :url('/HtmlSite/smarts4j_n/collaboration/resources/images/ic_collabo_help02.png') no-repeat center; vertical-align: middle; margin-top:-3px; margin-left: 5px;}
.help_ico:after { content: ""; position: absolute; bottom:0; left:50%; margin:0 0 -8px 0; border-width: 5px; border-style: solid; border-color: transparent transparent #4A86E8  transparent; transform:translate(-50%, 0); display:none; }
.help_ico.active:after { display:inline-block;  }
.helppopup { position:absolute; top:25px; left:0; min-width:200px; min-height:52px; background:#4A86E8; border-radius: 10px; color:#fff; padding:15px; font-size:13px; font-weight: 400; line-height: 22px; font-size:13px; z-index:99; display:none; }
.help_ico.active + .helppopup { display:inline-block; }
.help_p { margin:15px 0; padding:15px 0 0 0; border-top:1px solid #81abef; }
.help_p:first-child { margin:0; padding:0; border-top:none;}
.milstone_ic { display:inline-block; width:8px; height:8px; border:1px solid #fff; border-radius:2px; transform:rotate(45deg); vertical-align:top; margin:7px 5px 0 0; }
th .helppopup, td .helppopup { top:35px; }
.tip_wrap { position:relative; }

.source_exp{background-color:lightgray;padding-left:15px; }
</style>
<h3 class="con_tit_box">
	<span class="con_tit">개발지원 - 공통 Control</span>
</h3>
<div class="AXTabs">
	<div id="divTabTray" class="AXTabsTray" style="height: 30px">
			<a id="aSelectPage" href="javascript:;" onclick="clickTab(this);" class="AXTab on" value="Select">Select</a>
 			<a id="aFilePage" href="javascript:;" onclick="clickTab(this);"class="AXTab" value="File">File upload</a>
 			<a id="aCommentsPage" href="javascript:;" onclick="clickTab(this);"class="AXTab" value="Comments">댓글</a>
 			<a id="aCalendarPage"href="javascript:;" onclick="clickTab(this);" class="AXTab"value="Calendar">달력</a>
 			<a id="aCalendarViewPage" href="javascript:;"onclick="clickTab(this);" class="AXTab" value="CalendarView">표시용 달력</a>
 			<a id="aAutoComplete" href="javascript:;"onclick="clickTab(this);" class="AXTab" value="AutoComplete">자동완성</a>
 			<a id="aPickerPage" href="javascript:;" onclick="clickTab(this);"class="AXTab" value="Picker">Picker</a>
			<a id="aOrgChartPage" href="javascript:;" onclick="clickTab(this);" class="AXTab" value="OrgChart">조직도</a>
 			<a id="aEditorPage" href="javascript:;"onclick="clickTab(this);" class="AXTab" value="Editor">Editor</a>
 			<a id="aBoardPage" href="javascript:;"onclick="clickTab(this);" class="AXTab" value="Board">Grid</a>
 			<a id="aPopupPage" href="javascript:;"onclick="clickTab(this);" class="AXTab" value="Popup">Popup</a>
 			<a id="aInputPage" href="javascript:;"onclick="clickTab(this);" class="AXTab" value="Input">Input</a>
 			<a id="aEtcPage" href="javascript:;"onclick="clickTab(this);" class="AXTab" value="Etc">기타</a>
	</div>

	<div id="Select" class="mt15" >
		<!-- coviCtrl.renderAjaxSelect 시작 -->
		<div class="section_title mb10">coviCtrl.renderAjaxSelect <span class="subTitle">[기본 선택상자]</span></div>
		<div class="topbar_grid">
			<div id="sampleRenderAjaxDiv"></div>
			<div>
			기초코드(BaseCode) 값을 사용하여  SelectBox를 생성합니다. <br>
			※ onchange, oncomplete 함수의 사용은 브라우저 console log와 함께 봐주세요. 
			</div>
			<div>
				<input type="button" class="AXButton" value="초기화" onclick="reSelect('Ajax'); return false;">
				<input type="button" class="AXButton" value="값 변경" onclick="coviCtrl.setSelected('sampleRenderAjaxDiv', 'Common'); return false;">
				<input type="button" class="AXButton" value="값 조회" onclick="getRenderAjax(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>initInfos</th>
				<td>
					<strong>[필수] SelectBox가 그려지는데 필요한 정보를  JSON 형식으로 지정</strong>
					<ul style="margin-left: 20px;">
						<li><strong> [필수] target: select가 그려질 위치의 div 태그의  ID</strong></li>
						<li><strong> [필수] codeGroup: 기초코드의 코드그룹 값 </strong></li>
						<li> hasGroupCode: 코드그룹과 코드가 동일한 항목 표시여부 (Y[default]/N)</li>
						<li> defaultVal: 바인딩 후 기본 값 </li>
						<li> width: 가로 길이로 지정하지 않을 경우 별도  width 값 지정되지 않음</li>
						<li> onchange: 값 변경 시 호출될 함수로 호출 시 넘겨지는 매개변수 없음</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>oncomplete</th>
				<td>SelectBox 바인딩 완료 후 호출될 함수명으로 빈 값으로 지정할 경우 별도의 호출 없음</td>
			</tr>
			<tr>
				<th>lang</th>
				<td>option text 다국어를 지정하는 값으로 빈 값일 때는 기초코드 내 CodeName, 지정할 경우  MultiCodeName을 사용하여 넘어온 코드에 맞는 다국어 값 표시 </td>
			</tr>
		</table>
		<!-- coviCtrl.renderAjaxSelect 종료 -->
		
		<!-- coviCtrl.renderDomainAXSelect 시작 -->
		<div class="section_title mt65 mb10">coviCtrl.renderDomainAXSelect <span class="subTitle">[도메인 선택상자]</span></div>
		<div class="topbar_grid">
			<select id="sampleRenderDomainAXDiv" class="AXSelect"></select>
			<div>
			등록된 도메인을 선택할 수 있는  AXISJ SelectBox를 생성합니다. (covi_smart4j.sys_object_domain 조회)<br>
			관리자로 지정된 경우 관리권한이 있는 도메인만 바인딩되며 그룹사 관리자 또는 관리 권한이 없는 사용자의 경우 전체 도메인이 모두 바인딩됩니다. <br>
			※ onchange, oncomplete 함수의 사용은 브라우저 console log와 함께 봐주세요. 
			</div>
			<div>
				<input type="button" class="AXButton" value="초기화" onclick="reSelect('Domain'); $('#sampleRenderDomainAXDiv').bindSelectSetValue('ORGROOT'); return false;">
				<input type="button" class="AXButton" value="값 변경" onclick="$('#sampleRenderDomainAXDiv').bindSelectSetValue('CoviMall'); return false;">
				<input type="button" class="AXButton" value="hasAll" onclick = "getHasAll('Domain'); $('#sampleRenderDomainAXDiv').bindSelectSetValue(''); return false;">
				<input type="button" class="AXButton" value="option" onclick = "getOptionValue('Domain'); return false;">
				<input type="button" class="AXButton" value="값 조회" onclick="getRenderDomainAX(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] AXISJ SelectBox가 그려질 select 태그의  ID </strong></td>
			</tr>
			<tr>
				<th>lang</th>
				<td>option text 다국어를 지정하는 값으로 빈 값일 때는 도메인의  DisplayName, 지정할 경우  MultiDisplayName을 사용하여 넘어온 코드에 맞는 다국어 값 표시 </td>
			</tr>
			<tr>
				<th>onchange</th>
				<td>값 변경 시 호출될 함수로 호출 시 선택된 옵션정보 객체를 매개변수로 넘김</td>
			</tr>
			<tr>
				<th>oncomplete</th>
				<td>SelectBox 바인딩 완료 후 호출될 함수명으로 빈 값으로 지정할 경우 별도의 호출 없음 (호출 시 매개변수 없음)</td>
			</tr>
			<tr>
				<th>defaultVal</th>
				<td>바인딩 후 기본 값  </td>
			</tr>
			<tr>
				<th>hasAll</th>
				<td> option 내 전체옵션 포함 여부  (true/false)</td>
			</tr>
			<tr>
				<th>options</th>
				<td>codeType의 값이 CODE일 경우  optionObj.optionValue값을 DomainID에서 DomainCode로 변경</td>
			</tr>
		</table>
		<!-- coviCtrl.renderDomainAXSelect 종료 -->
		
		<!-- coviCtrl.renderCompanyAXSelect 시작 -->
		<div class="section_title mt65 mb10">coviCtrl.renderCompanyAXSelect <span class="subTitle">[회사 선택상자]</span></div>
		<div class="topbar_grid">
			<select id="sampleRenderCompanyAXDiv" class="AXSelect"></select>
			<div>
			등록된 회사를 선택할 수 있는  AXISJ SelectBox를 생성합니다. (covi_smart4j.sys_object_group 조회)<br>
			타입이 'Company'인 그룹들을 조회합니다.<br>
			※ onchange, oncomplete 함수의 사용은 coviCtrl.renderDomainAXSelect와 동일하여 생략합니다. 
			</div>
			<div>
				<input type="button" class="AXButton" value="초기화" onclick="reSelect('Company'); return false;">
				<input type="button" class="AXButton" value="값 변경" onclick="$('#sampleRenderCompanyAXDiv').bindSelectSetValue(Common.getSession('DN_Code')); return false;">
				<input type="button" class="AXButton" value="hasAll" onclick = "getHasAll('Company'); $('#sampleRenderDomainAXDiv').bindSelectSetValue(''); return false;">
				<input type="button" class="AXButton" value="option" onclick = "getOptionValue('Company'); return false;">
				<input type="button" class="AXButton" value="값 조회" onclick="getRenderCompanyAX(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] AXISJ SelectBox가 그려질 select 태그의  ID </strong></td>
			</tr>
			<tr>
				<th>lang</th>
				<td>option text 다국어를 지정하는 값으로 빈 값일 때는 현재 다국어 값, 지정할 경우 지정된 다국어 코드를 사용하여 MultiDisplayName 값을 알맞게 표시</td>
			</tr>
			<tr>
				<th>onchange</th>
				<td>값 변경 시 호출될 함수로 호출 시 선택된 옵션정보 객체를 매개변수로 넘김</td>
			</tr>
			<tr>
				<th>oncomplete</th>
				<td>SelectBox 바인딩 완료 후 호출될 함수명으로 빈 값으로 지정할 경우 별도의 호출 없음 (호출 시 매개변수 없음)</td>
			</tr>
			<tr>
				<th>defaultVal</th>
				<td>바인딩 후 기본 값  </td>
			</tr>
			<tr>
				<th>hasAll</th>
				<td>option 내 전체옵션 포함 여부 (true/false)</td>
			</tr>
			<tr>
				<th>options</th>
				<td>codeType의 값이 ID일 경우  optionObj.optionValue값을 DomainID에서 GroupID로 변경</td>
			</tr>
		</table>
		<!-- coviCtrl.renderCompanyAXSelect 종료 -->
		
		<!-- coviCtrl.renderAXSelect 시작 -->
		<div class="section_title mt65 mb10">coviCtrl.renderAXSelect<span class="subTitle">[기본 선택상자(필수선택)]</span></div>
		<div class="topbar_grid">
			<select id="sampleRenderAXDiv1" class="AXSelect"></select>
			<select id="sampleRenderAXDiv2" class="AXSelect"></select>
			<div>
			기초코드(BaseCode) 값을 사용하여  <u>1개 이상의</u> AXISJ SelectBox를 생성합니다. <br>
			※ onchange, oncomplete 함수의 사용은 coviCtrl.renderDomainAXSelect와 동일하여 생략합니다.  
			</div>
			<div>
				<input type="button" class="AXButton" value="첫번째 박스 값 변경" onclick="$('#sampleRenderAXDiv1').bindSelectSetValue('Base'); return false;">
				<input type="button" class="AXButton" value="첫번째 박스 값 조회" onclick="getRenderAX(1); return false;">
				<input type="button" class="AXButton" value="두번째 박스 값 변경" onclick="$('#sampleRenderAXDiv2').bindSelectSetValue('com'); return false;">
				<input type="button" class="AXButton" value="두번째 박스 값 조회" onclick="getRenderAX(2); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>pCodeGroups</th>
				<td><strong>[필수] 기초코드의 코드그룹 값으로 1개의 이상의 SelectBox 바인딩 시 구분자는 , 사용 </strong></td>
			</tr>
			<tr>
				<th>pTargets</th>
				<td><strong>[필수] AXISJ SelectBox가 그려질 select 태그의  ID로 1개의 이상의 SelectBox 바인딩 시 구분자는 , 사용 </strong></td>
			</tr>
			<tr>
				<th>lang</th>
				<td>option text 다국어를 지정하는 값으로 빈 값일 때는 기초코드 내 CodeName, 지정할 경우  MultiCodeName을 사용하여 넘어온 코드에 맞는 다국어 값 표시하며  모든 SelectBox에 동일하게 적용됨</td>
			</tr>
			<tr>
				<th>onchange</th>
				<td>값 변경 시 호출될 함수로 호출 시 선택된 옵션정보 객체를 매개변수로 넘기며 1개의 이상의 SelectBox 바인딩 시 구분자는 , 사용</td>
			</tr>
			<tr>
				<th>oncomplete</th>
				<td>SelectBox 바인딩 완료 후 호출될 함수명으로 빈 값으로 지정할 경우 별도의 호출 없으며 1개의 이상의 SelectBox 바인딩 시 구분자는 , 사용</td>
			</tr>
			<tr>
				<th>defaultVal</th>
				<td>바인딩 후 기본 값으로  1개의 이상의 SelectBox 바인딩 시 구분자는 , 사용</td>
			</tr>
			<tr>
				<th>hasAll</th>
				<td>option 내 전체옵션 포함 여부 (true/false)</td>
			</tr>
			<tr>
				<th>expGroup</th>
				<td>codeType이 false이거나 true이면서 목록의 옵션값이 동일할 때 codeObj.Code값으로 변경</td>
			</tr>
		</table>
		<!-- coviCtrl.renderAXSelect 종료 -->
		
		<!-- select tag 사용 -->
		<covi:select className="selectType02 listCount" id="listCntSel" boxType="PAGE"></covi:select>
		
		<div class="section_title mt65 mb10">selectbox 커스텀 태그 활용<span class="subTitle">[커스텀 태그 covi:select]</span></div>
		<div class="topbar_grid">
			<div style="color:red">※ 중요[taglib 설정 후  사용가능]</div>
			소스 예시<br>
			<div class="source_exp">	
				&lt;%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %&gt; <br>
				&lt;covi:select id="sampleRenderAXDiv1" className="" boxType="PAGE"&gt; &lt;/covi:select&gt;<br> 
				&lt;covi:select id="sampleRenderAXDiv2" className="" boxType="YEAR"&gt; <br> 
				&ltoption value=""&gt;<spring:message code='Cache.lbl_Whole' />&lt/option&gt;<br>
				&lt;/covi:select&gt; 
			</div>
			
			<div>
			boxType을 통하여 유형에 맞는 값 출력 <br>
			※ className 제외 다른 옵션은 select와 동일하게 사용 
			</div>
		</div>
		<div class="mb5"><b>- boxType</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>PAGE</th>
				<td><strong>PAGE 형태로 제공  
					<div cols=100>&lt;covi:select id="sampleRenderAXDiv1" className="selectType02" boxType="PAGE"&gt;&lt;/covi:select&gt;</div>
					</strong>
					<covi:select id="sampleRenderAXDiv1" className="selectType02" boxType="PAGE"></covi:select>
				</td>
			</tr>
			<tr>
				<th>YEAR</th>
				<td><strong>년도 형태로 제공  
					<div cols=100>&lt;covi:select id="sampleRenderAXDiv1" className="selectType02" boxType="YEAR"&gt;&lt;/covi:select&gt;</div>
					</strong>
					<covi:select id="sampleRenderAXDiv1" className="selectType02" boxType="YEAR"></covi:select>
				</td>
			</tr>
			<tr>
				<th>CODE</th>
				<td><strong>기초코드 데이타 
					<div cols=100>
						&lt;covi:select id="sampleRenderAXDiv1" boxType="CODE" codeGroups="VACATION_TYPE"&gt;<br>
						&ltoption value=""&gt;<spring:message code='Cache.lbl_Whole' />&lt/option&gt;<br>
						&lt;/covi:select&gt;</div>
					</strong>
					<covi:select id="sampleRenderAXDiv1"  boxType="CODE" codeGroups="VACATION_TYPE">
						<option value=""><spring:message code='Cache.lbl_Whole' /></option>
					</covi:select>
				</td>
			</tr>
			<tr>
				<th>DB</th>
				<td><strong>쿼리를 기반으로 한 데이타 
					<div cols=100>
						&lt;covi:select id="sampleRenderAXDiv1" queryId="devhelper.acl.selectDeptListSelect" boxType="DB"&gt;<br>
						&ltoption value=""&gt;<spring:message code='Cache.lbl_Whole' />&lt/option&gt;<br>
						&lt;/covi:select&gt;</div>
					</strong>
					<covi:select id="sampleRenderAXDiv1"  boxType="DB" queryId="devhelper.acl.selectDeptListSelect">
						<option value=""><spring:message code='Cache.lbl_Whole' /></option>
					</covi:select>
				</td>
			</tr>
		</table>	
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>id</th>
				<td><strong>컴포넌트 아이디 </strong></td>
			</tr>
			<tr>
				<th>boxType</th>
				<td><strong>서버에서 내려줄 리스트 형태</strong></td>
			</tr>
			<tr>
				<th>disabled</th>
				<td>disable 여부</td>
			</tr>
			<tr>
				<th>selected</th>
				<td>option 값중 selected 로 세팅할 값</td>
			</tr>
			<tr>
				<th>className</th>
				<td>class 사용시 이름</td>
			</tr>
			<tr>
				<th>startYear</th>
				<td>boxType이 YEAR일 경우 시작년도 (없을 시 현재년도-34 예: 2023이면 2019)</td>
			</tr>
			<tr>
				<th>yearSize</th>
				<td>시작년도 부터 증가할 최대값(없을 시 6년)</td>
			</tr>
			<tr>
				<th>style</th>
				<td>style값</td>
			</tr>
			<tr>
				<th>codeGroups</th>
				<td>boxType이 CODE일 경우 codeGroup명</td>
			</tr>
			<tr>
				<th>queryId</th>
				<td>boxType이 DB일 경우 실행할 쿼리 이름
					<br>
					쿼리작성시 주의사항: 쿼리 alias로 select 의 함목이랑 매핑
					 Value, Text, Step(select box에 option에 공백 추가 갯수)
					 <div class="source_exp">	
					 SELECT gr.GroupCode as "Value" <br>
							,gr.MultiDisPlayName) as "Text"<br>   
							,LENGTH(GR.SORTPATH) - LENGTH(REPLACE(GR.SORTPATH,';','')) as "Step"<br>
						FROM sys_object_group gr 
					</div>	
				</td>
			</tr>
			<tr>
				<th>onclick</th>
				<td></td>
			</tr>
			<tr>
				<th>onchange</th>
				<td></td>
			</tr>
		</table>
		<!-- select tab 종료 -->
		
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.control.js</li>
						<li>/smarts4j.framework/src/main/java/egovframework/coviframework/taglib/SelectboxTag.java</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>참고 사이트</th>
				<td>
					AXISJ 참고 사이트 - 해당 사이트에서 AXSelect 위주로 참고하시면 됩니다. 
					<ul style="margin-left: 20px;">
						<li><a target="_blank" href="https://dev.axisj.com/samples/AXSelect/index.html">https://dev.axisj.com/samples/AXSelect/index.html</a></li>
						<li><a target="_blank" href="http://jdoc.axisj.com/document/index.html">http://jdoc.axisj.com/document/index.html</a></li>
						<li><a target="_blank" href="https://github.com/thomasJang/axisj">https://github.com/thomasJang/axisj</a></li>
					</ul>
				</td>
			</tr>
		</table>
	</div>


	<div id="File" class="mt15">
		<div class="section_title mb10">coviFile.renderFileControl <span class="subTitle">[기본 파일 업로드(Back Storage)]</span></div>
		
		<!-- coviFile.renderFileControlEx1 시작 -->
		<div id="sampleRenderFileControlEx1"></div>
		<div class="topbar_grid mt10">
			<b>[예제1]</b> <br>
			게시판, 일정관리, 자원예약 등에서 사용하는 가장 일반적인 형태의 파일업로드로 [등록]버튼을 표시하지 않아 Front Storage에 파일을 올리지 않습니다.<br>
			각 모듈에서 파일 저장이 필요한 시점 (게시물 등록, 일정 등록, 자원 예약 등)에 FileUtilService를 이용하여 Back Storage에 파일을 업로드합니다. <br>
			또한, 웹하드 파일을 추가하는 [웹하드] 버튼은 기초설정 isUseWebhard가 'Y'이고, 기초설정 useWebhardAttach가 'Y'일 경우 자동 표시됩니다. <br>
			※ 현재 예제에서는 파일 재 업로드 시 기존 파일은 제거되며 업로드 경로는 '/gwstorage/Devhelper' 이니 참고 바랍니다.<br>
			<div>
				<input type="button" class="AXButton" value="파일 업로드 (To Back)" onclick="uploadBackRenderFileControlEx1(); return false;">
				<input type="button" class="AXButton" value="파일목록 조회 (From Back)" onclick="getBackRenderFileControlEx1(); return false;">
			</div>
		</div>
		<!-- coviFile.renderFileControlEx1  종료 -->
		
		<!-- coviFile.renderFileControlEx2 시작 -->
		<div id="sampleRenderFileControlEx2"></div>
		<div id="imgRenderFileControlEx2" class="mt10 mb10" style="min-height: 100px; text-align: center">
			<img src="" onerror= "coviCmn.imgError(this)" style="width: 100px; height:100px; overflow:hidden "/>
		</div>
		<div class="topbar_grid mt10">
			<b>[예제2]</b> <br>
			댓글에서 사용하는 파일업로드 방식으로 썸네일 표시 등을 위해 Storage에 올려야하지만 실제 등록여부를 알 수 없는 파일을 우선 FrontStorage에 업로드합니다.<br>
			FrontStorage에 업로드하기 위하여 [등록]버튼을 표시하며 각 모듈에서는 FileUtilService를 이용하여 Back Storage로 파일을 이동시킵니다. <br>
			또한, 웹하드 파일을 추가하는 [웹하드] 버튼은 기초설정 isUseWebhard가 'Y'이고, 기초설정 useWebhardAttach가 'Y'일 경우 자동 표시됩니다. <br>
			※ 현재 예제에서 Back Storage 경로는 '/gwstorage/Devhelper' 이니 참고 바랍니다.<br>
			<div>
				<input type="button" class="AXButton" value="파일 업로드 (To Front)" onclick="uploadFrontRenderFileControlEx2(); return false;">
				<input type="button" class="AXButton" value="파일 이동 (Front → Back)" onclick="moveToBackRenderFileControlEx2(); return false;">
			</div>
		</div>
		<!-- coviFile.renderFileControlEx1  종료 -->
		
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable mb10">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] 파일 업로드 컨트롤이 그려질 div 태그의 ID</strong></td>
			</tr>
			<tr>
				<th>option</th>
				<td>
					<strong>[필수] 파일 업로드 컨트롤이 그려지는데 필요한 정보를 JSON 형식으로 지정</strong>
					<ul style="margin-left: 20px;">
						<li><strong> [필수] listStyle: 파일컨트롤 내 row가 table 태그로 구성될지 div 태그로 구성될지 여부로 디자인 차이는 없음 (table/div)</strong></li>
						<li><strong> [필수] actionButton: 표시될 버튼으로  add(추가)와 upload(등록)가 있고 구분자는 , 사용</strong></li>
						<li> image: true일 경우 이미지만 업로드 가능 (true/false[default]) </li>
						<li> multiple: 1개 이상의 파일 첨부 허용 여부 (true[default]/false)</li>
						<li> callback: 등록 버튼 클릭하여 Front에 파일이 Upload 된 후 호출될 함수명으로 빈값일 경우 별도 호출 없음 </li>
						<li> servicePath: 등록 버튼 클릭하여 Front에 파일을 Upload할 때 Back에 위치한 파일을 합쳐서 처리할 경우 back 경로를 지정하는 값으로 그런 경우가 없다면 지정하지 않아도 무관(sys_storage정보 이용 이후 사용하지 않는 값, 서버에서 file정보로 back경로 조회)</li>
						<li> fileSizeLimit: 업르드 가능한 파일의 최대 사이즈로 지정하지 않을 경우 200MB</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>data</th>
				<td>기존 파일 목록으로 렌더링 시 기존 파일 목록은 row로 추가되며 없을 경우 생략 가능</td>
			</tr>
		</table>
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/ControlCon.java</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.file.js</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/DevHelperCon.java</li>
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>관련 설정 값</th>
				<td>
					BackStorage, FrontStorage에 대한 경로 지정은 웹서버 또는 톰캣 설정에 지정되어 있어야합니다.  
					<br><br>
					globals.properties
					<ul style="margin-left: 20px;">
						<li>attachUNIX.path/attachWINDOW.path: BackStorage의 실제 폴더 경로로 gwstorage 폴더가 위치한 폴더 (ex. 빈 값 또는 C:/eGovFrame-3.5.1)</li>
						<li>frontUNIX.path/frontWINDOW.path: FrontStorage의 실제 폴더 경로 (ex. /frontStorage 또는 C:/eGovFrame-3.5.1/FrontStorage )</li>
					</ul>
					기초설정 값
					<ul style="margin-left: 20px;">
						<li>EnableFileExtention: 업로드 가능한 확장자 </li>
						<li>EnableFileImageExtention: 이미지 전용 업로드일 경우 업로드 가능한 확장자</li>
					</ul>
				</td>
			</tr>
			
			<tr>
				<th>파일 다운로드</th>
				<td>
					다운로드는 공통함수인 Common.fileDownLoad(파일ID, 원본 파일명, 파일 TOKEN);을 사용하시면됩니다.<br> 
					또한, 현재 파일 목록 조회 방법은 예제1의 [파일목록 조회] 참고 바랍니다.  
				</td>
			</tr>
			<tr>
				<th>허용 확장자</th>
				<td>
					컨트롤을 통해 파일을 Front Storage에 올리는 상황 외에는 모듈 별로 서버 단에서 FileUtil.isEnableExtention 함수를 사용하여 확장자를 체크해야합니다. <br>
					<ul style="margin-left: 20px;">
						<li>option의 image가 true일 경우 허용할 확장자 추가: EnableFileImageExtention(기초설정), EnableFileExtention(기초설정)에 확장자 추가 </li>
						<li>option의 image가 false일 경우 허용할 확장자 추가: EnableFileExtention(기초설정)에 확장자 추가 </li>
					</ul>
					<div class="mt10">※ 기초설정 변경 시 Redis 기초설정 초기화 및 캐시초기화 후 확인 바랍니다.</div>
				</td>
			</tr>
			<tr>
				<th>썸네일 생성</th>
				<td>
					확장자가 jpg, jpeg, png, gif, bmp일 경우 썸네일이 생성됩니다. 
				</td>
			</tr>
		</table>
	</div>

	<div id="Comments" class="mt15">
		<div class="section_title mb10">coviComment.load <span class="subTitle">[기본 댓글 로드]</span></div>
		
		<!-- coviComment.load 시작 -->
		<div class="topbar_grid mt10">
			댓글 등록 및 조회 가능한 컨트롤을 제공합니다. <br>
			( CSS Include 문제로 팝업으로 예제 표시합니다. ) 
			<div>
				<input type="button" class="AXButton" value="댓글 업로드창 조회" onclick="popupCoviCommentLoad(); return false;">
			</div>
		</div>
		
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable mb10">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>elemID</th>
				<td><strong>[필수] 댓글 컨트롤이 그려질 div 태그의 ID</strong></td>
			</tr>
			<tr>
				<th>targetServiceType</th>
				<td><strong>[필수] 댓글이 등록될 서비스 BizSection 값 (ex. 게시판-Board, 일정관리-Schedule, 자원예약-Resource) </strong></td>
			</tr>
			<tr>
				<th>targetID</th>
				<td>
					<strong>[필수] 댓글이 등록될 서비스 내에서 객체를 구분할 수 있는 값으로 (targetServiceType, targetID)가 유니크한 값이 되도록 지정</strong><br>
					참고: 일정과 자원예약의 경우 eventID, 게시판은 messageID_version을 targetID로 사용 
				</td>
			</tr>
			<tr>
				<th>msgSetting</th>
				<td>댓글 알림을 보낼 경우 알림 설정값을  JSON 형식으로 지정 (상세 지정값은 모듈별로 알림에 맞게 지정)</td>
			</tr>
			<tr>
				<th>folderType</th>
				<td>최상위 객체 coviComment객체 안에 있는 commentVariables객체 folderType저장</td>
			</tr>
		</table>
		
		<div class="mb5"><b>- Method</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>save</th>
				<td>
					댓글/답글 작성 후 저장. 댓글 컨트롤이 그려질 div 태그의 ID 전달
					<ul style="margin-left: 20px;">
						<li>coviComment.save('sampleCoviCommentLoad')</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>addLikeCount</th>
				<td>
					특정   답글에 좋요아요를 표시. elemID, targetServiceType, targetID 전달 
					<ul style="margin-left: 20px;">
						<li>coviComment.addLikeCount(this, 'Comment', '1734')</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>callReWrite</th>
				<td>
					댓글에 답글 작성. elem, elemID, commentID 전달
					<ul style="margin-left: 20px;">
						<li>coviComment.callReWrite(this, elemID, row.CommentID)</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>deleteComment</th>
				<td>
					기존에 있던 댓글/답글을 삭제. elemID, commentID, memberOf 전달 
					<ul style="margin-left: 20px;">
						<li>coviComment.deleteComment(elemID, row.CommentID, row.MemberOf)</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>editComment</th>
				<td>
					등록된 댓글/답글 수정. elem, elemID, commentID, parentID 전달 후 수정 영역 노출
					<ul style="margin-left: 20px;">
						<li>coviComment.editComment(this, 'sampleCoviCommentLoad', '1734', '0')</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>edit</th>
				<td>
					editComment함수에서 수정된 댓글/답글 값을 업데이트. elemID, commentID 전달, 수정 재확인 창 을 띄우고 수정된 댓글을 저장
					<ul style="margin-left: 20px;">
						<li>coviComment.editComment(this, 'sampleCoviCommentLoad', '1734', '0')</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>callImgUpload</th>
				<td>
					파일 업로드 팝업 호출. 댓글 컨트롤이 그려질 div 태그의 ID 전달 이후 동작은 coviFile에서 실행(이미지 제외 파일은 업로드 불가)
					<ul style="margin-left: 20px;">
						<li>coviComment.callImgUpload(elemID)</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>callFileUpload</th>
				<td>
					파일 업로드 팝업 호출. 댓글 컨트롤이 그려질 div 태그의 ID 전달 이후 동작은 coviFile에서 실행
					<ul style="margin-left: 20px;">
						<li>coviComment.callFileUpload(elemID)</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>callImageViewer</th>
				<td>
					이미지 파일 상세보기 팝업 호출. 이미지 element ID 전달 이후 동작은 coviFile에서 실행
					<ul style="margin-left: 20px;">
						<li>coviComment.callImageViewer('/covicore/common/view/2125.do')</li>
					</ul>
				</td>
			</tr>
		</table>
		<!-- coviComment.load 종료 -->
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/CommentCon.java</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.comment.js</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/PopupComment.jsp</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>

	<div id="Calendar" class="mt15">
		<!-- coviCtrl.makeSimpleCalendar 시작 -->
		<div class="section_title mb10">coviCtrl.makeSimpleCalendar <span class="subTitle">[기본 달력 컨트롤]</span></div>
		<div class="topbar_grid">
			<div id="sampleMakeSimpleCalendarDiv" class="dateSel"></div>
			<div>
			날짜를 지정할 수 있는 달력 컨트롤을 제공합니다. <br>
			별도로 지정하지 않을 경우 초기값은 현재 날짜로 셋팅됩니다. 
			</div>
			<div>
				<input type="button" class="AXButton" value="값 변경" onclick="setMakeSimpleCalendar(); return false;">
				<input type="button" class="AXButton" value="값 조회" onclick="getMakeSimpleCalendar(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] 달력 컨트롤이 그려질 span 또는 div 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>defaultDate</th>
				<td>초기값. 지정하지 않을 시 오늘 날짜로 셋팅 </td>
			</tr>
		</table>
		<!-- coviCtrl.makeSimpleCalendar 종료 -->
		
		<!-- coviCtrl.renderDateSelect 시작 -->
		<div class="section_title mt65 mb10">coviCtrl.renderDateSelect <span class="subTitle">[시간 지정 달력 컨트롤]</span></div>
		<div class="topbar_grid">
			<div id="sampleRenderDateSelectDiv" class="dateSel"></div>
			<div>
			SelectBox로 시간의 범위를 지정할 수 있는 달력 컨트롤을 제공합니다. <br>
			옵셥 값을 조정하여 시간 범위 값을 변경 수 있고 날짜 또는 시간 Input을 안보이게 할 수도 있으며 시간과 분을 분리할 수도 있습니다. <br>
			별도로 변경하지 않을 경우 초기값은 현재 날짜로 셋팅됩니다. 
			</div>
			<div>
				<input type="button" class="AXButton" value="값 변경" onclick="setRenderDateSelect(); return false;">
				<input type="button" class="AXButton" value="값 조회" onclick="getRenderDateSelect(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] 달력 컨트롤이 그려질 div 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>timeInfos</th>
				<td>
					<strong>[필수] 시간 범위 SelecBox의 옵션을 지정하는 값으로 JSON 형식으로 지정 (모든 옵션 구분자 ,)</strong>
					<ul style="margin-left: 20px;">
						<li><strong>[필수] H: 시간 선택 값으로  '(입력 값)시간'으로 범위 SelectBox의 옵션이 생성 (Ex. H : '2,3,5' 로 입력하였을 경우, 옵션이  2시간, 3시간, 5시간으로 생성)</strong></li>
						<li><strong>[필수] W: 주 선택 값</strong></li>
						<li><strong>[필수] M: 달 선택 값</strong></li>
						<li><strong>[필수] Y: 년도 선택 값</strong></li>
					</ul>
				
				</td>
			</tr>
			<tr>
				<th>initInfos</th>
				<td>
					<strong>[필수] 달력 컨트롤이 그려지는데 필요한 설정 정보를  JSON 형식으로 지정</strong>
					<ul style="margin-left: 20px;">
						<li><strong>[필수] useCalendarPicker: 날짜 선택 Input 사용여부 (Y/N)</strong></li>
						<li><strong>[필수] useTimePicker: 시간 선택 SelecBox 사용여부  (Y/N)</strong></li>
						<li>[useTimePicker가 Y일 경우 필수] useSeparation: 시간 선택 시 시와 분 분리 여부 </li>
						<li>[useTimePicker가 Y일 경우 필수] minuteInterval: 분 시간 단위로 지정한 값이 60의 약수가 아닌 경우 그려지지 않음.</li>
						<li>changeTarget: 범위 값 수정 시 변경대상이 될 값으로 start의 경우 end값 기준으로 start값이 변경되고, end일 경우 start값 기준으로 end값이 변경(start/end[default])</li>
						<li>use59: TimePicker의 59분이 들어갈지 여부로 Y일 경우 minuteInteval 값에 상관없이 59분이 추가된다. (Y/N[default]))</li>
					</ul>
				</td>
			</tr>
		</table>
		<!-- coviCtrl.renderDateSelect 종료 -->
		
		<!-- coviCtrl.renderDateSelect2 시작 -->
		<div class="section_title mt65 mb10">coviCtrl.renderDateSelect2 <span class="subTitle">[시간 분리 지정 달력 컨트롤]</span></div>
		<div class="topbar_grid">
			<div id="sampleRenderDateSelect2Div" class="dateSel"></div>
			<div>
			날짜와 시간을 지정할 수 있는 달력 컨트롤을 제공합니다. <br>
			옵셥 값을 조정하여 날짜 또는 시간 Input을 안보이게 할 수도 있으며 시간과 분을 분리할 수도 있습니다.
			</div>
			<div>
				<input type="button" class="AXButton" value="값 변경" onclick="setRenderDateSelect2(); return false;">
				<input type="button" class="AXButton" value="값 조회" onclick="getRenderDateSelect2(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] 달력 컨트롤이 그려질 div 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>initInfos</th>
				<td>
					<strong>[필수] 달력 컨트롤이 그려지는데 필요한 설정 정보를  JSON 형식으로 지정</strong>
					<ul style="margin-left: 20px;">
						<li><strong>[필수] useCalendarPicker: 날짜 선택 Input 사용여부 (Y/N)</strong></li>
						<li><strong>[필수] useTimePicker: 시간 선택 SelecBox 사용여부  (Y/N)</strong></li>
						<li>[useTimePicker가 Y일 경우 필수] useSeparation: 시간 선택 시 시와 분 분리 여부 </li>
						<li>[useTimePicker가 Y일 경우 필수] minuteInterval: 분 시간 단위로 지정한 값이 60의 약수가 아닌 경우 그려지지 않음.</li>
						<li>changeTarget: 범위 값 수정 시 변경대상이 될 값으로 start의 경우 end값 기준으로 start값이 변경되고, end일 경우 start값 기준으로 end값이 변경(start/end[default])</li>
						<li>use59: TimePicker의 59분이 들어갈지 여부로 Y일 경우 minuteInteval 값에 상관없이 59분이 추가된다. (Y/N[default]))</li>
					</ul>
				</td>
			</tr>
		</table>
		<!-- coviCtrl.renderDateSelect2 종료 -->
		
		<!-- coviCtrl.renderDateSelect3 시작 -->
		<div>
		<div class="section_title mt65 mb10">coviCtrl.renderDateSelect3 <span class="subTitle">[중복일 체크 달력 컨트롤]</span></div>
		<div class="topbar_grid">
			<div>
			renderDateSelect2함수와 동일하게 날짜와 시간을 지정할 수 있는 달력 컨트롤을 제공합니다. <br>
			옵셥 값을 조정하여 날짜 또는 시간 Input을 안보이게 할 수도 있으며 시간과 분을 분리할 수도 있습니다.<br>
			renderDateSelect3에서는 이미 등록된 날짜를  체크합니다.
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] 달력 컨트롤이 그려질 div 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>initInfos</th>
				<td>
					<strong>[필수] 달력 컨트롤이 그려지는데 필요한 설정 정보를  JSON 형식으로 지정</strong>
					<ul style="margin-left: 20px;">
						<li><strong>[필수] useCalendarPicker: 날짜 선택 Input 사용여부 (Y/N)</strong></li>
						<li><strong>[필수] useTimePicker: 시간 선택 SelecBox 사용여부  (Y/N)</strong></li>
						<li>[useTimePicker가 Y일 경우 필수] useSeparation: 시간 선택 시 시와 분 분리 여부 </li>
						<li>[useTimePicker가 Y일 경우 필수] minuteInterval: 분 시간 단위로 지정한 값이 60의 약수가 아닌 경우 그려지지 않음.</li>
						<li>changeTarget: 범위 값 수정 시 변경대상이 될 값으로 start의 경우 end값 기준으로 start값이 변경되고, end일 경우 start값 기준으로 end값이 변경(start/end[default])</li>
						<li>use59: TimePicker의 59분이 들어갈지 여부로 Y일 경우 minuteInteval 값에 상관없이 59분이 추가된다. (Y/N[default]))</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>num</th>
				<td>중복 일 체크</td>
			</tr>
		</table>
		</div>
		<!-- coviCtrl.renderDateSelect3 종료 -->
		
		<!-- AXInput.bindDate 시작 -->
		<div class="section_title mt65 mb10">AXISJ Date Control</div>
		<div class="topbar_grid">
			<div style="line-height:20px;"><strong>[Date]</strong></div>
			<input type="text" class="AXInput W90" kind="date" date_separator="/" />  
			<div style="line-height:20px;" class="mt5"><strong>[Year, Month]</strong></div>
			<input type="text" class="AXInput W50" kind="date" date_selectType="y"/>&nbsp;<input type="text" class="AXInput W70" kind="date" date_selectType="m"/>
			<div style="line-height:20px;" class="mt5"><strong>[TwinDate]</strong></div>
			<input type="text" id="startdate" class="AXInput W90" /> ~ <input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" class="AXInput W90" />
			
			<div>
			AXISJ 라이브러리에서 제공하는 달력 컨트롤입니다. <br>
			공통 함수에서 화면 load시 바인딩을 시키기 때문에 별도의 컨트롤 바인딩 함수 호출이 필요없습니다. (바인딩이 되지 않거나 컨트롤 위치가 이상한 경우 coviInput.setDate(); 함수 호출) <br>
			주로 관리자 사이트 개발시에 사용하며 대표적인 예제만 만들었으니 상세한 예제는 아래 참고사항 - 참고 사이트 확인 바랍니다. <br>
			※ 값 변경 및 조회는 일반적인 Input 태그와 동일하여 생략합니다. 			
			</div>
		</div>
		<!-- AXInput.bindDate 종료 -->
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/CommonControls.js (AXISJ 바인딩)</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.control.js</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>참고 사이트</th>
				<td>
					AXISJ 참고 사이트 - 해당 사이트에서 AXInput 중 Date 위주로 참고하시면 됩니다. <br>
					AXInput.bindDate 함수 호출은 CommonControl.js의 coviInput.setDate() 함수 참고 바랍니다. 
					<ul style="margin-left: 20px;">
						<li><a target="_blank" href="https://dev.axisj.com/samples/AXInput/calendar.html">https://dev.axisj.com/samples/AXInput/calendar.html</a></li>
						<li><a target="_blank" href="http://jdoc.axisj.com/document/index.html">http://jdoc.axisj.com/document/index.html</a></li>
						<li><a target="_blank" href="https://github.com/thomasJang/axisj">https://github.com/thomasJang/axisj</a></li>
					</ul>
				</td>
			</tr>
		</table>
	</div>
	
	<div id="AutoComplete" class="mt15">
		<!-- coviCtrl.setCustomAjaxAutoTags 시작 -->
		<div class="section_title mb10">coviCtrl.setCustomAjaxAutoTags <span class="subTitle">[입력 자동완성 컨트롤(Ajax)]</span></div>
		<div class="topbar_grid">
			<div class="autoCompleteCustom">
				<input id="sampleSetCustomAjaxAutoTagsDiv" type="text" class="ui-autocomplete-input" >
			</div>
			<div>
			Ajax를 통해 가져온 데이터를 사용하여 자동완성 Input을 생성합니다.<br>
			예제에서는 조직도 그룹 및 사용자 정보를 가지고 컨트롤을 생성하였으니 테스트 시  참고 바랍니다.<br>
			※ callback 함수의 사용은 브라우저 console log와 함께 봐주세요. 
			</div>
			<div>
				<input type="button" class="AXButton" value="태그목록 변경" onclick="setSetCustomAjaxAutoTags(); return false;">
				<input type="button" class="AXButton" value="태그목록 조회" onclick="getSetCustomAjaxAutoTags(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] 자동완성 컨트롤이 그려질 input 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>url</th>
				<td><strong>[필수] 호출될 Ajax URL로 사용자가 입력한 텍스트는 파라미터 'keyword'로 넘어감 </strong></td>
			</tr>
			<tr>
				<th>option</th>
				<td>
					<strong>[필수] 자동완성 컨트롤이 그려지는데 필요한 정보를  JSON 형식으로 지정</strong>
					<ul style="margin-left: 20px;">
						<li><strong>[필수] labelKey: AJax를 통해 가져온 데이터 중 Label 역할을 할 속성 Key</strong></li>
						<li><strong>[필수] valueKey: AJax를 통해 가져온 데이터 중 Value 역할을 할 속성 Key</strong></li>
						<li>multiselect: 1개 이상의 데이터 선택 가능 여부 (true/false[default])</li>
						<li>useEnter: multiselect 값이 true 일 때 자동완성되지 않는 데이터 입력하고 사용자가 Enter를 치는 경우 태그로 등록할지 여부 (true/false[default])</li>
						<li>minLength: 자동완성 데이터를 검색할 최소 글자수로 지정하지 않을 경우 1</li>
						<li>useDuplication: 중복된 데이터 허용여부 (true/false[default])</li>
						<li>callType: 메일 시스템과 구분을 두기 위한 Type으로  메일이 아닐 경우 지정하지 않아도 됨(Mail/빈값 또는 미지정)</li>
						<li>callBackFunction: 자동완성 데이터 선택 시 호출될 함수명으로 선택된 데이터가 매개변수로 넘거가며 지정하지 않을 경우 별도 호출없음</li>
						<li>select: 자동완성 데이터 선택 시 Tag가 생기는 기본 select함수와 다른 처리를 하고 싶은 경우 처리 함수 지정 </li>
					</ul>
				</td>
			</tr>
		</table>
		<!-- coviCtrl.setCustomAjaxAutoTags 종료 -->
		
		<!-- coviCtrl.setCustomAutoTags 시작 -->
		<div class="section_title mt65 mb10">coviCtrl.setCustomAutoTags <span class="subTitle">[입력 자동완성 컨트롤(Json)]</span></div>
		<div class="topbar_grid">
			<div class="autoCompleteCustom">
				<input id="sampleSetCustomAutoTagsDiv" type="text" class="ui-autocomplete-input" >
			</div>
			<div>
			JSONArray 데이터를 사용하여 자동완성 Input을 생성합니다.<br>
			예제는 과일이름 자동완성으로 작성하였으니 테스트 시 참고 바랍니다 (ex. 사과, 오렌지 등)<br>
			※ callback 함수의 사용은 브라우저 console log와 함께 봐주세요. 
			</div>
			<div>
				<input type="button" class="AXButton" value="태그목록 변경" onclick="setSetCustomAutoTags(); return false;">
				<input type="button" class="AXButton" value="태그목록 조회" onclick="getSetCustomAutoTags(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] 자동완성 컨트롤이 그려질 input 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>source</th>
				<td><strong>[필수] 자동완성에 사용될 JSONArray 데이터</strong></td>
			</tr>
			<tr>
				<th>option</th>
				<td>
					<strong>[필수] 자동완성 컨트롤이 그려지는데 필요한 정보를  JSON 형식으로 지정</strong>
					<ul style="margin-left: 20px;">
						<li><strong>[필수] labelKey: AJax를 통해 가져온 데이터 중 Label 역할을 할 속성 Key</strong></li>
						<li><strong>[필수] valueKey: AJax를 통해 가져온 데이터 중 Value 역할을 할 속성 Key</strong></li>
						<li>multiselect: 1개 이상의 데이터 선택 가능 여부 (true/false[default])</li>
						<li>useEnter: multiselect 값이 true 일 때 자동완성되지 않는 데이터 입력하고 사용자가 Enter를 치는 경우 태그로 등록할지 여부 (true/false[default])</li>
						<li>minLength: 자동완성 데이터를 검색할 최소 글자수로 지정하지 않을 경우 1</li>
						<li>useDuplication: 중복된 데이터 허용여부 (true/false[default])</li>
						<li>callBackFunction: 자동완성 데이터 선택 시 호출될 함수명으로 선택된 데이터가 매개변수로 넘거가며 지정하지 않을 경우 별도 호출없음</li>
						<li>select: 자동완성 데이터 선택 시 Tag가 생기는 기본 select함수와 다른 처리를 하고 싶은 경우 처리 함수 지정 </li>
					</ul>
				</td>
			</tr>
		</table>
		<!-- coviCtrl.setCustomAutoTags 종료 -->
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.control.js</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/ControlCon.java</li>
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>
	
	<div id="Picker" class="mt15">
		<!-- coviCtrl.renderColorPicker 시작 -->
		<div class="section_title mb10">coviCtrl.renderColorPicker <span class="subTitle">[컬러픽커]</span></div>
		<div class="topbar_grid">
			<div id="sampleRenderColorPickerDiv"></div>
			<div>
			색깔을 선택할 수 있는 컨트롤을 생성합니다.
			</div>
			<div>
				<input type="button" class="AXButton" value="값 변경" onclick="setRenderColorPicker(); return false;">
				<input type="button" class="AXButton" value="값 조회" onclick="getRenderColorPicker(); return false;">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] Color Picker 컨트롤이 그려질 div 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>colorInfos</th>
				<td>
					<strong>[필수] 선택가능한 색깔 목록을 JSON 형식으로 지정 (key-value 형식으로 지정)</strong>
					<ul style="margin-left: 20px;">
						<li><strong> [필수] key: 색상이 선택 되었을 때 16진수 값과 함께 return 받을 색상의 이름</strong></li>
						<li><strong> [필수] value:목록에 보여질 색깔의 코드로 '#16진수' (Ex.#FFFFFF) </strong></li>
					</ul>
				</td>
			</tr>
		</table>
		<!-- coviCtrl.renderColorPicker 종료 -->
	
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/resources/script/palette-color-picker.js</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.control.js</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>
	
	<div id="OrgChart" class="mt15">
		<!-- 조직도 팝업 시작 -->
		<div class="section_title mb10">조직도 팝업</div>
		<div>
			<div style="display:inline">
				<select id="sampleOrgChartPopupType" class="AXSelect" style="border: 1px solid #d6d6d6;">
					<option value="" selected>조직도 타입(type)</option>
					<option value="A0">A0 [직원 조회용]</option>
					<option value="B1">B1 [사용자 1명 선택]</option>
					<option value="B9">B9 [사용자  여러명 선택]</option>
					<option value="C1">C1 [그룹 1개 선택]</option>
					<option value="C9">C9 [그룹 여러개 선택]</option>
					<option value="D1">D1 [사용자/그룹 1개 선택]</option>
					<option value="D9">D9 [사용자/그룹 여러개 선택]</option>
					<option value="MAIL">MAIL [메일용/사용자/그룹 여러개 선택]</option>
					<option value="TEAMS">TEAMS [TEMAS용/사용자/그룹 여러개 선택]</option>
				</select>
				<select id="sampleOrgChartPopupTreeKind" class="AXSelect" style="border: 1px solid #d6d6d6;">
					<option value="" selected>트리 종류(treeKind)</option>
					<option value="Dept">Dept [부서 조직도]</option>
					<option value="Group">Group [그룹 조직도]</option>
				</select>
				<select id="sampleOrgChartPopupAllCompany" class="AXSelect" style="border: 1px solid #d6d6d6;">
					<option value="" selected>타회사 포함여부(allCompany)</option>
					<option value="Y">Y [포함]</option>
					<option value="N">N [포함하지 않음]</option>
				</select>
				<select id="sampleOrgChartPopupBizcardKind" class="AXSelect" style="border: 1px solid #d6d6d6;">
					<option value="" selected>연락처 포함여부(bizcardKind)</option>
					<option value="ALL">ALL [포함]</option>
					<option value="">미지정 [포함하지 않음]</option>
				</select>
			</div>
			<div style="display:inline; float:right;">
				<input type="button" class="btnTypeDefault" style="margin-bottom:2px;" value="조직도 호출" onclick="goOrgChartPopup(); return false;">
			</div>
			<div class="mt5 mb5">
				<textarea id="sampleOrgChartPopupTextarea" rows="5" placeholder=" 조직도 callBack 데이터가 표시됩니다." json-value="true" style="width: 100%;box-sizing: border-box;padding-right: 1px;border: 1px solid #d6d6d6;border-radius: 2px;resize: none;"></textarea>
			</div>
		</div>		
		<br>
		<div>
		<div class="mb5"><b>- 조직도 팝업 호출 방법</b></div>
		<div class="topbar_grid">
			<!-- goOrgChart.do을 사용하여 호출 할 경우 type에 따라 다른 파일을 호출하게 됩니다.</br> -->
			예 1-1) Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true)<br>
			1. 조직도 팝업 버튼 태그 생성</br>
			2. 태그안에 onclick속성 생성 후 example()함수안에 필요한 URL Parameter 전달</br>
			3. example()함수에서 예)1-1과 같이  goOrgChart.do가 포함된 url을 open함수로 실행</br></br>
			※type에 따라 호출되는 파일이 달라지게 됩니다.
			<ul style="margin-left: 20px;">
				<li>MAIL: covision.orgchart.mail.js를 페이지에 추가 - 없는경우 진행</li>
				<li>TEAMS: covision.orgchart.teams.js를 페이지에 추가 - 없는경우 진행</li>
				<li>A0: covision.orgchart.A0.js를 페이지에 추가 - 없는경우 진행</li>
				<li>그 외: ovision.orgchart.js를 페이지에 추가 - 없는경우 진행</li>
			</ul>
		</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>URL 예시</th>
				<td>
					/covicore/control/goOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=D9&groupDivision=Basic&CFN_OpenLayerName=orgmap_pop<br>
					/covicore/control/goOrgChart.do? <strong>URL Parameter없이도 동작 가능</strong>
					<ul style="margin-left: 20px;">
						
					</ul>	
				</td>
			</tr>
		</table>
		</div>
		
		</br>
		<div class="topbar_grid">
			URL Parameter 값을 변경하여 용도에 맞는 조직도를 호출할 수 있습니다. 
		</div>
		<div class="mb5"><b>- URL Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>openerID</th>
				<td>팝업에서 조직도 팝업을 호출할 경우 호출한 팝업 ID (팝업에서 호출 시 입력하지 않을 경우 초기값 설정 및 callBack 함수 호출에 문제가 있을 수 있음) </td>
			</tr>
			<tr>
				<th>type</th>
				<td>
					cmmn/controls/OrgChart.jsp 에서 분기 처리
					<ul style="margin-left: 20px;">
						<li>MAIL(D9): coviOrgMail.render함수 실행</li>
						<li>TEAMS(D9): coviOrgTeams.render함수 실행</li>
						<li>A0: coviOrgA0.render함수 실행</li>
						<li>그 외: coviOrg.render함수실행</li>
					</ul>	
					조직도 타입으로 조직도 용도(조회/선택), 대상(사용자/그룹), 수(1개/N개)를 지정
					<ul style="margin-left: 20px;">
						<li>A0: 직원 조회용</li>
						<li>B1: 사용자 1명 선택</li>
						<li>B9: 사용자  여러명 선택</li>
						<li>C1: 그룹 1개 선택</li>
						<li>C9: 그룹 여러개 선택</li>
						<li>D1: 사용자/그룹 1개 선택</li>
						<li>D9: 사용자/그룹 여러개 선택 [default]</li>
					</ul>	
				</td>
			</tr>
			<tr>
				<th>treeKind</th>
				<td>
					조직도에 표시될 트리 종류 지정
					<ul style="margin-left: 20px;">
						<li>Dept: 부서 트리만 표시 [default]</li>
						<li>Group: 부서 트리와 그룹 트리 표시</li>
					</ul>	
				</td>
			</tr>
			<tr>
				<th>allCompany</th>
				<td>전체 계열사 표시 여부로 N일 경우 현재 세션의 계열사만 표시 (Y[default]/N)	</td>
			</tr>
			<tr>
				<th>callBackFunc</th>
				<td>조직도에서 확인버튼 클릭 시 호출될 함수명으로 매개변수로 선택된 사용자/그룹 정보가 넘어가며 지정하지 않을 경우 별도 호출 없음</td>
			</tr>
			<tr>
				<th>setParamData</th>
				<td>선택형 조직도 호출 시 초기값 셋팅이 필요한 경우 셋팅값 JSON을 가지고 있을 변수명</td>
			</tr>
			<tr>
				<th>bizcardKind</th>
				<td>인명관리 연락처 표시 여부로  표시할 경우 ALL(ALL/빈값 또는 미지정 [default])</td>
			</tr>
		</table>
		<!-- 조직도 팝업 종료 -->
	
		<!-- coviOrg.render 시작 -->
		<div class="section_title mt65 mb10">coviOrg.render <span class="subTitle">[조직도, 자동완성 입력 조직도]</span></div>
		<div id="sampleCoviOrgRenderDiv" ></div>
		<div class="topbar_grid" style="clear:both;">
			<div>
			조직도의 각 부분을 선택하여 바인딩 할 수 있습니다. <br>
			예를들어 전자결재 내 결재선 지정창에서는 트리와 사용자 조회 부분만 coviOrg.render 함수를 이용하여 바인딩 하고 있습니다. <br>
			Parameter는 조직도 바인딩에 필요한 정보를 JSON형식으로 정의한 'orgOpt' 하나로 아래에서는 orgOpt의 key에 대해 설명하겠습니다. <br>
			※ 예제는 drawOpt를 LM___로 지정하여 작성하였으니 참고 바랍니다. 
			</div>
		</div>
		<div class="mb5"><b>- orgOpt 구성값</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>targetID</th>
				<td><strong>[필수] 조직도가 그려질 div 태그의 ID</strong></td>
			</tr>
			<tr>
				<th>drawOpt</th>
				<td>
					조직도의 다섯 부분 중 그려질 부븐을 지정하는 값으로 5자리로 구성되며 그리지 않을 부분은 '_'로 입력 (기본값은 'LMARB')<br>
					※ 그려지지 않는 부분이 있을 경우 그에 맞게 다른 옵션을 지정 (ex. L영역을 그리지 않을 경우 M영역을 그려도 별도 처리하지 않는 이상 그리는 의미가 없음)
					<div class="mt5" style="width:675px;">
						<img src="/covicore/resources/images/devhelper/orgchartPart.jpg" onerror="coviCmn.imgError(this);" style="width:675px;"/>
					</div>
				</td>
			</tr>
			<tr>
				<th>type</th>
				<td>
					조직도 타입으로 조직도 용도(조회/선택), 대상(사용자/그룹), 수(1개/N개)를 지정하는 값으로 
					<ul style="margin-left: 20px;">
						<li>A0: 직원 조회용</li>
						<li>B1: 사용자 1명 선택</li>
						<li>B9: 사용자  여러명 선택</li>
						<li>C1: 그룹 1개 선택</li>
						<li>C9: 그룹 여러개 선택</li>
						<li>D1: 사용자/그룹 1개 선택</li>
						<li>D9: 사용자/그룹 여러개 선택 [default]</li>
					</ul>	
				</td>
			</tr>
			<tr>
				<th>treeKind</th>
				<td>
					조직도에 표시될 트리 종류 지정
					<ul style="margin-left: 20px;">
						<li>Dept: 부서 트리만 표시 [default]</li>
						<li>Group: 부서 트리와 그룹 트리 표시</li>
					</ul>	
				</td>
			</tr>
			<tr>
				<th>allCompany</th>
				<td>전체 계열사 표시 여부로 N일 경우 현재 세션의 계열사만 표시 (Y[default]/N)	</td>
			</tr>
		</table>
		<!-- coviOrg.render 종료 -->
	
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/ControlCon.java</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.orgchart.js (기본 조직도)</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.orgchart.A0.js (조회용 조직도)</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.orgchart.mail.js (메일용 조직도)</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.orgchart.teams.js (teams용 조직도)</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>	
	
	<div id="Editor" class="mt15">
		<div class="section_title mb10">coviEditor <span class="subTitle">[코비 에디터]</span></div>
		<!-- coviEditor.loadEditor 시작 -->
		<div id="sampleLoadEditorDiv"></div>
		<div id="sampleLoadEditorPreviewDiv" style="display:none;">
			<div class="mb5 mt10"><b>[Editor 내용]</b></div>
			<div id="sampleLoadEditorPreview" style="border: 1px solid #b2b1b1; padding: 7px; "></div>
		</div>
		<div class="topbar_grid mt10">
			지정한 옵션에 맞게 Editor를 생성합니다. <br>
			본문에 첨부하는 인라인 이미지는 우선적으로 Front Storage로 올라가며 각 모듈에서 파일 저장이 필요한 시점에 EditorService를 이용하여 Back Storage로 이동시킵니다. <br>
			※ 예제에서는 기초설정 값 EditorType에 따라 바인딩되는 Editor가 달라지니 참고바랍니다. ( 현재 EditorType: <span id="sampleLoadEditorType"></span> ) <br>
			※ 기초설정 ImageServiceURL이 서버 URL로 잡혀있을 경우 로컬에서는 인라인 이미지 이동 후 정상표시 되지 않을 수 있으니 개발자 도구를 사용하여 경로 이동된 것만 확인해주세요.
			<div>
				<input type="button" class="AXButton" value="Editor 내용 변경" onclick="setLoadEditor(); return false;">
				<input type="button" class="AXButton" value="Editor 내용 조회" onclick="getLoadEditor(); return false;">
				<input type="button" class="AXButton" value="인라인 이미지 이동(Front → Back)" onclick="moveToBackLoadEditor(); return false;">
			</div>
		</div>
		
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<td><strong>[필수] Editor가 그려질 div 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>option</th>
				<td>
					<strong>[필수] Editor가 그려지는데 필요한 정보를  JSON 형식으로 지정</strong>
					<ul style="margin-left: 20px;">
						<li>
							<strong>[필수] editorType: 표시할 Editor 타입의 이름 또는 번호 지정</strong> <br>
							<b>&lt;지원하는 Editor&gt;</b>
							<ul style="margin-left: 20px;">
								<li>Dext5 Editor: 'dext5' 또는 '8'로 지정</li>
								<li>Synap Editor: 'synap' 또는 '10'으로 지정</li>
							</ul>
						</li>
						<li><strong>[필수] containerID: Editor 프레임의 name 값을 임의로 지정</strong></li>
						<li>frameHeight: Editor 높이로 지정하지 않은 경우 600px</li>
						<li>focusObjID: 바인딩 완료 후 포커스를 받을 객체 ID로 없을 시 빈값 또는 미지정</li>
						<li>useResize: Editor 높이 변경 버튼 표시 여부 (Y/N[default])</li>
						<li>bizSection: 모듈 별 아이디 (ex. 게시판-Board, 일정관리-Schedule, 자원예약-Resource)</li>
						<li>onLoad: 바인딩 완료 후 실행될 함수명(string) 또는 함수(function)로 지정하지 않을 경우 별도 호출 없음</li>
					</ul>
				</td>
			</tr>
		</table>
		<!-- coviEditor.loadEditor  종료 -->
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.editor.js</li>
						<li>/smarts4j.framework/src/main/java/egovframework/coviframework/util/DEXT5Handler.java (Dext5 용)</li>
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/SynapEditorCon.java (Synap 용)</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Dext5 폴더 (Dext5 용)</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/SynapEditor 폴더 (Synap 용)</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/DevHelperCon.java</li>
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>관련 설정 값</th>
				<td>
					globals.properties
					<ul style="margin-left: 20px;">
						<li>gwStorageInlineAttach.path: Front Storage 내부 경로로  (frontUNIX.path/frontWINDOW.path) + gwStorageInlineAttach.path 위치에 인라인 이미지 업로드</li>
						<li>frontUNIX.path/frontWINDOW.path: FrontStorage의 실제 폴더 경로 (ex. /frontStorage 또는 C:/eGovFrame-3.5.1/FrontStorage )</li>
      					<li>smart4j.path: 그룹웨어 URL (ex. https://gw4j.covision.co.kr) </li>
					</ul>
					기초설정 값
					<ul style="margin-left: 20px;">
						<li>dext5EditorURL: Dext5 폴더 URL (외부로 빠져있을 경우 옵션 값 수정 시 외부 파일을 수정)</li>
						<li>synapEditorURL: Synap 폴더 URL (외부로 빠져있을 경우 옵션 값 수정 시 외부 파일을 수정)</li>
						<li>synapConverterPath: Synap 폴더 Path (외부로 빠져있을 경우 옵션 값 수정 시 외부 파일을 수정)</li>
						<li>xfreeEditorURL: XFree 폴더 URL (외부로 빠져있을 경우 옵션 값 수정 시 외부 파일을 수정)</li>
						<li>ckEditorURL: CKEditor 폴더 URL (외부로 빠져있을 경우 옵션 값 수정 시 외부 파일을 수정)</li>
						<li>webhwpctrlEditorURL: 웹한글기안기 폴더 URL (외부로 빠져있을 경우 옵션 값 수정 시 외부 파일을 수정) </li>
						<li>EditorType.path: Editor 종류 </li>
						<li>ImageServiceURL: BackStorage URL (ex. https://gw4j.covision.co.kr) </li>
						<li>FrontStorage: FrontStorage URL 경로 (ex. /FrontStorage )</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>인라인 이미지 </th>
				<td>
					HTML 내 인라인 이미지 경로를 Front Storage에서 Back Storage로 replace 시킬 때 이미지  URL 경로는 아래와 같은 기준으로 replace 되니 참고 바랍니다.
					<ul style="margin-left: 20px;">
						<li>Front Storage: globals.properties의 smart4j.path + 기초설정 값 (key: FrontStorage)</li>
						<li>Back Storage: 기초설정 값 (key: ImageServiceURL)  + sys_storage 테이블의 모듈 별 InlineURL 값 (운영체제가 WINDOWS일 경우 Reserved3 값 바라봄)</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>참고 사이트</th>
				<td>
					각 Editor의 라이선스 적용, 옵션 값에 대한 설명은 Editor별 사이트 참고 바랍니다.  
					<ul style="margin-left: 20px;">
						<li>Dext5 Editor: <a target="_blank" href="http://www.dext5.com/page/develop/editor.aspx">http://www.dext5.com/page/develop/editor.aspx</a></li>
						<li>Synap Editor: <a target="_blank" href="https://synapeditor.com/docs/display/SE">https://synapeditor.com/docs/display/SE</a></li>
					</ul>
				</td>
			</tr>
		</table>
	</div>		
	
	<div id="CalendarView" class="mt15">
		<div class="section_title mb10">CoviCalendar <span class="subTitle">[표시용 달력]</span></div>
		<!-- coviEditor.loadEditor 시작 -->
		<div id="sampleCalendarViewDiv" style="width:50%;"></div>
		<div id="sampleCalendarViewPreviewDiv" style="display:none;">
			<div class="mb5 mt10"><b></b></div>
			<div id="sampleCalendarViewPreview" style="border: 1px solid #b2b1b1; padding: 7px; "></div>
		</div>
		<div class="topbar_grid mt10">
			<div>
			* 사용법: CoviCalendar(calid, option)<br>
			1. jquery를 페이지에 추가(의존성) - 없는경우 진행<br>
			2. covision.calendar.js를 페이지에 추가 - 없는경우 진행<br>
			3. covision.calendar.css를 페이지에 추가 - 없는경우 진행<br>
			4. 페이지에 달력이 그려질 컨테이너 div 추가. id 부여<br>
			<br>
			document.ready에서 CoviCalendar 함수를 실행 ex) var myCalendar = CoviCalendar('calendarTest')<br>
			함수에서 div id 위치에 달력을 그리고, 달력 객체를 반환
			</div>
		</div>
		
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>calid</th>
				<td><strong>[필수] 표시용 달력이 그려질 div 태그의 ID (string)</strong></td>
			</tr>
			<tr>
				<th>option</th>
				<td>
					[선택] 달력 생성 시 사용되는 옵션 (object)
					<ul style="margin-left: 20px;">
						<li>startWeekday: sun/mon/tue/wed/thu/fri/sat 중 1. 달력의 주일 시작요일 설정. 기본 일요일</li>
						<li>lineHeight: 높이 + 'px' 달력의 행 높이. 기본 30px</li>
						<li>today: 표시 월. 기본 new Date()</li>
						<li>weekLine: 숫자 또는 auto, 주 수 설정. auto일 경우 5-6주 가변적으로 표시됨. 5 = 5주, 6 = 6주 </li>
					</ul>
				</td>
			</tr>
		</table>
		
		<div class="mb5"><b>- Method</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>setMark</th>
				<td>
					전달한 날짜에 대해 달력에 언더바를 표시. YYYY-MM-DD 날짜 또는 날짜의 배열을 인자로 전달.
					<ul style="margin-left: 20px;">
						<li>myCalendar.setMark('2022-12-07')</li>
						<li>myCalendar.setMark(['2022-12-07','2022-12-08','2022-12-09','2022-12-17'])</li>
						<li>test
							<input type="text" id="markday" placeholder="마킹할 날짜를 입력하세요. (YYYY-MM-DD)" style="width: 270px; margin-left: 10px;"/>
							<input type="button" onclick="javascript:coviCalSetMark()" value="실행" style="height: 26px; margin-left: 10px; width: 50px;"/>
						</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>cleaerMark</th>
				<td>
					달력에 표시된 날짜의 마킹 해제. YYYY-MM-DD 날짜 전달 시 특정일 해제, 인자가 없을 경우 전체 해제
					<ul style="margin-left: 20px;">
						<li>myCalendar.clearMark('2022-12-07')</li>
						<li>myCalendar.clearMark()</li>
						<li>test <input type="button" onclick="javascript:coviCalClearMark()" value="실행" style="height: 26px; margin-left: 10px; width: 50px;"/></li>
					</ul>
				</td>
			</tr>
		</table>
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>콜백 처리</th>
				<td>
					달력이 변경되면, calid에 load 이벤트를 트리거함.<br>
					달력을 사용하는 기능에서 해당 이벤트를 받아 콜백을 구성 가능<br>
					ex) $("#calendarTest").on("load", function(){ console.log('콜백처리'); });<br>
				</td>
			</tr>
			<tr>
				<th>관련 설정 값</th>
				<td>
				</td>
			</tr>
		</table>
	</div>	
	
	<div id="Board" class="mt15">
		<div class="section_title mb10">coviGrid <span class="subTitle">[코비 그리드]</span></div>
		<!-- 게시판 목록 리스트 시작 -->
		<div id="divListView" class="tblList tblCont">
			<div id="messageGrid"></div>
		</div>
		
		<div class="topbar_grid mt10">
			통합게시(BoardList.jsp)메뉴에서 사용하는 Grid 함수 기준으로 작성되었습니다.</br>
			※ 예제에서는 board_message 테이블 데이터를 가져오므로 데이터가 없을 경우 통합게시와 동일하게 뜨지 않습니다.
		</div>
		
		<div class="section_title mt65 mb10">coviGrid.setGridHeader(pHeader)</div>
		<div class="topbar_grid mt10">
			그리드의 헤더를 셋팅합니다.
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>pHeader</th>
				<th>Array</th>
				<td>
					<div>헤더의 표시할 항목들을 객체로 생성하여 Array형태로 전달</div>
					<div>ex) {key:'RegistDate', label:'등록일', width:'30', align:'center',sort:"desc"}</div>
					<div>
						<ul style="padding-left: 20px; list-style: disc;">
							<li><b>key: </b> 조회 쿼리의 키 값</li>
							<li><b>label: </b> 표시 이름</li>
							<li><b>width: </b> 너비</li>
							<li><b>align: </b> 데이터 정렬방식</li>
							<li><b>sort: </b>오름차순/내림차순, 쿼리에서 정렬 처리를 해줘야 합니다.</li>
						</ul>
					</div>
				</td>
			</tr>
		</table>
		
		<div class="section_title mt65 mb10">coviGrid.setGridConfig(pObj)</div>
		<div class="topbar_grid mt10">
			그리드의 기능을 셋팅합니다. (그리드가 표시될 요소의 id, 페이징 관련)
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>pObj</th>
				<th>Object</th>
				<td>
					<div>그리드의 설정값을 Object로 전달</div>
					<div>ex) { targetID: "messageGrid", height: "auto", page: { pageSize: 5 }, paging: true }</div>
					<div>
						<ul style="padding-left: 20px; list-style: disc;">
							<li><b>targetID: </b> Grid가 그려지는 div id 명</li>
							<li><b>height: </b> 그리드 높이</li>
							<li><b>page: </b> 페이지 설정을 객체로 저장.
								<ul style="padding-left: 20px; list-style: disc;">
									<li><b>pageSize: </b> 한 페이지에 보여지는 데이터 수</li>
									<li><b>pageNo: </b> 조회할 페이지 번호</li>
								</ul>
							</li>
							<li><b>paging: </b> 페이징 여부. boolean</li>
						</ul>
					</div>
				</td>
			</tr>
		</table>
		
		<div class="section_title mt65 mb10">coviGrid.bindGrid(pListData)</div>
		<div class="topbar_grid mt10">
			데이터를 가져와 그리드를 설정에 따라 그립니다.
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>pListData</th>
				<th>Array/Object</th>
				<td>
					<div>그리드에 데이터를 Array로 전달하거나, AJAX url 속성을 Object로 전달합니다.</div>
					<div>ex) { ajaxUrl:"/covicore/devhelper/boardGridSample.do", ajaxPars: { pageSize: messageGrid.page.pageSize, ... } }</div>
					<div>
						<ul style="padding-left: 20px; list-style: disc;">
							<li><b>ajaxUrl: </b> 데이터를 가져올 ajax url</li>
							<li><b>ajaxPars: </b> ajax 호출시 전달할 파라미터를 Object로 설정. (옵션)</li>
						</ul>
					</div>
				</td>
			</tr>
		</table>
		
		<div class="section_title mt65 mb10">사용법</div>
		<div class="topbar_grid mt10">
			<ul style="padding-left: 20px; list-style: decimal;">
				<li>
					<div>그리드 객체 생성</div>
					<div>var messageGrid = new coviGrid();</div>
				</li>
				<li>
					<div>그리드 헤더 설정</div>
					<div>messageGrid.setGridHeader([{key:'MessageID', label:'번호', width:'10', align:'center'}, ...]);</div>
				</li>
				<li>
					<div>그리드 설정</div>
					<div>messageGrid.setGridConfig({"옵션1": "값", ...});</div>
				</li>
				<li>
					<div>데이터 바인드</div>
					<div>messageGrid.bindGrid({</div>
					<div>	ajaxUrl:"/covicore/devhelper/boardGridSample.do",</div>
					<div>	ajaxPars: { pageSize: messageGrid.page.pageSize, ... }</div>
					<div>});
				</li>
			</ul>
		</div>
		
		<!--  grid tag 활용 -->
	<div class="section_title mt65 mb10">grid 커스텀 태그 활용<span class="subTitle">[커스텀 태그 covi:table]</span></div>
		<div class="topbar_grid">
			<div style="color:red">※ 중요[taglib 설정 후  사용가능]</div>
			소스 예시<br>
			<div class="source_exp">	
				&lt;%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %&gt; <br>
				&lt;covi:grid id="gridDiv" gridVar="<font color=red>vacationManageGrid</font>" pageCookie="VacListCnt" pageSize="10"&gt;<br>
					&lt;tr&gt;<br>
					  &lt;td key="VacYear"		label="lblNyunDo"	        width="50"  align="center" /&gt;<br>
					  &lt;td key="DeptName"	label="lbl_dept"	        width="60"  align="center"  formatter="DIC" /&gt;<br>
					  &lt;td key="DisplayName"	label="lbl_username"	width="50"  align="center"  formatter="FLOWER" formatAddtion="UR_Code,DisplayName"/&gt;<br>
					  &lt;td key="VacText"	label="VACATION_TYPE_VACATION_TYPE"	width="50"  align="center"  formatter="CUSTOM" formatAddtion="vacationVacationListByUse.formatVacText"/&gt;<br>
					&lt;/tr&gt;  <br>
				&lt;/covi:grid&gt;<br><br>
				
				&lt;script&gt;<br>
				var grid  = new coviGrid();<br>
				// vacationManageGrid_header; //헤더에 값을 추가시 추가 후 config 세팅<br>
				grid.setGridConfig(<font color=red>vacationManageGrid</font>);<br>
				&lt;/script&gt;
			</div>
			
			<div>
			formatter 함수를 통하여 그리드 옵션을 제어 <br>
			</div>
		</div>
		<div class="mb5"><b>grid - Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>id</th>
				<td><strong>grid를 그려넣을 targetid</strong>
				</td>
			</tr>
			<tr>
				<th>gridVar</th>
				<td><strong>grid 변수</strong>
				</td>
			</tr>
			<tr>
				<th>pageCookie</th>
				<td><strong>pagesize를 세팅할 쿠키값(없을 시 pagesize로 세팅) </strong>
				</td>
			</tr>
			<tr>
				<th>pageSize</th>
				<td><strong>page size (없을시 기본값 :10) </strong>
				</td>
			</tr>
		</table>	
		<div class="mb5"><b>td - Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>key</th>
				<td><strong>컴포넌트 아이디 </strong></td>
			</tr>
			<tr>
				<th>label</th>
				<td><strong>서버에서 내려줄 리스트 형태</strong></td>
			</tr>
			<tr>
				<th>width</th>
				<td></td>
			</tr>
			<tr>
				<th>align</th>
				<td>없을 시 center</td>
			</tr>
			<tr>
				<th>sort</th>
				<td>없을 시 sort </td>
			</tr>
			<tr>
				<th>disabled</th>
				<td>checkbox 일 경우 disable 조건이 들어가는 함수 추가
				소스 예시<br>
				<div class="source_exp">	
					설정 예: disabled="vacationVacationCancelManager.disableCancelChk" <br>
					함수 예:<br>
					this.disableCancelChk = function(item){
						return Number(item.VacDayTot)<=0;
					}
				</div>	
				</td>
			</tr>
			<tr>
				<th>addClass</th>
				<td>컬럼에 추가 할 클래스</td>
			</tr>
			<tr>
				<th>display</th>
				<td>출력 여부 default 출력</td>
			</tr>
			<tr>
				<th>hideFilter</th>
				<td>필터값에 추가 여부 defulat 추가</td>
			</tr>
			<tr>
				<th>linkEvent</th>
				<td>컬럼 클릭시 이벤트 함수 설정
				소스 예시<br>
				<div class="source_exp">	
					설정 예: linkEvent="vacationVacationManage.openVacationUpdatePopup" <br>
					함수 예:<br>
						this.openVacationUpdatePopup=function(item) {<br>
							let urCode = item.UR_Code;
							let year = item.YEAR;
							var parYear = $("#schYearSel option:selected").val();<br>
							Common.open("","target_pop","<spring:message code='Cache.lbl_apv_Vacation_days' />","/groupware/vacation/goVacationUpdatePopup.do?urCode="+urCode+"&year="+parYear,"499px","281px","iframe",true,null,null,true);<br>
						}
				</div>	
				</td>
			</tr>
			<tr>
				<th>formatter</th>
				<td><strong>컬럼에 대한 format </strong>
				소스 예시<br>
					<table class="AXFormTable">
						<colgroup>
							<col width="150px;"/>
							<col width="150px;"/>
							<col width="*"/>
						</colgroup>
						<tr><th>formatter</th><th>내용</th><th>사용예</th></tr>
						<tr><th>money,dec,html,checkbox,radio</th><td>기존 axgrid 지원함수</td><td>formatter="checkbox"</td></tr>
						<tr><th>SWITCH</th><td>on/off 지원</td>
							<td>
								<div class="source_exp">	
								설정 예: formatter="SWITCH"  formatAddtion="UR_Code" callback="vacationVacationManage.switchUse"<br>
								함수 예:<br>
									this.switchUse= function (retKey, val) {<br>
										retKey //formatAddtion에서 세팅한 key값<br>
										val    //switch on : Y /off:N<br>
									}	
								
								</div>	
							</td>
						</tr>
						<tr><th>CUSTOM</th><td>개발 지원함수</td>
							<td>
								<div class="source_exp">	
								설정 예: formatter="CUSTOM" formatAddtion="vacationVacationManage.formatGubunName"<br>
								함수 예:<br>
									this.formatGubunName=function (item){<br>
										var html = "&lt;div&gt;";
										var gubunName = item.GubunName;
										if (item.GUBUN == 'VACATION_PUBLIC' || item.GUBUN == 'VACATION_APPLY') {
											html += "&lt;a href='#' onclick='vacationVacationManage.openVacationCancelPopup(\"" + item.VacationInfoID + "\", \"" + item.VacYear + "\"); return false;'&gt;";
											html += gubunName;
											html += "&lt;/a&gt;";
										} else {
											html += gubunName;
										}
										html += "&lt;/div&gt;";<br>
									
										return html;<br>
									}
								</div>
							</td></tr>
						<tr><th>DIC,TERM,FLOWER,LINK,DATE,NUMBER</th><td>공통 format 함수</td><td>formatter="FLOWER" <br>참고:covision.common.js의 getCoviGridFormat 함수</td></tr>
					</table>
				</td>
			</tr>
			<tr>
				<th>formatAddtion</th>
				<td>formatter=""SWITCH" 일 경우 return 받을 key <br>
				formatter="CUSTOM" 일 경우 처리할 함수명</td>
			</tr>
			<tr>
				<th>callback</th>
				<td>formatter=SWITCH일 경우 swith 이벤트 발생시 return받을 함수 </td>
			</tr>
		</table>
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/CommonControls.js</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/axisj/AXGrid.js</li>
						<li>/smarts4j.framework/src/main/java/egovframework/coviframework/util/ComUtils.java (리스트갯수 및 페이징)</li>
						<li>/smarts4j.groupware/src/main/java/egovframework/covision/groupware/util/BoardUtils.java (sorting)</li>
						<li>/smarts4j.framework/src/main/java/egovframework/coviframework/taglib/GridTag.java</li>
						<li>/smarts4j.framework/src/main/resources/META-INF/resources/WEB-INF/views/tags/gridEnd.jsp</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/DevHelperCon.java</li>
						<li>/smarts4j.covicore/src/main/java/egovframework/core/sevice/impl/DevHelperSvcImpl.java</li>
						<li>/smarts4j.covicore/src/main/resources/sqlmap/sql/mysql/common_control_board.xml</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>	
	
	<div id="Popup" class="m15">
		<!-- Common.open 시작 -->
		<div class="section_title mb10" style="margin-top:15px">Common.open <span class="subTitle">[팝업 컨트롤]</span></div>
		<div class="topbar_grid">
			<div id="sampleRenderColorPickerDiv"></div>
			<div>
			선택한 위치에서 레이어 팝업을 실행시킵니다.
			</div>
			<div>
				<input type="button" class="btnTypeDefault" id="help_ico" style="margin-bottom:2px;" onclick="javascript:openFunction()" value="마우스를  클릭하세요">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>button_id</th>
				<th>String</th>
				<td>함수를 호출한 id의 값</td>
			</tr>
			<tr>
				<th>object_id</th>
				<th>String</th>
				<td>
					<strong>[필수] 레이어 팝업 형태를 생성할때 id에 들어가는 값</strong>
				</td>
			</tr>
			<tr>
				<th>title</th>
				<th>String</th>
				<td>
					<strong>[필수] 레이어 팝업의 title </strong>
				</td>
			</tr>
			<tr>
				<th>source</th>
				<th>String</th>
				<td>
					<strong>[필수] 레이어 팝업 안에 들어갈 HTML</strong>
				</td>
			</tr>
			<tr>
				<th>w</th>
				<th>String</th>
				<td>
					<strong>[필수] 레이어 팝업의 width(px필수)</strong>
				</td>
			</tr>
			<tr>
				<th>h</th>
				<th>String</th>
				<td>
					<strong>[필수] 레이어 팝업의 height(px필수)</strong>
				</td>
			</tr>
			<tr>
				<th>pMode</th>
				<th>String</th>
				<td>
					<strong>[필수] 컨텐츠 로드 방식</strong>
				</td>
			</tr>
			<tr>
				<th>pIsModal</th>
				<th>Boolean</th>
				<td>
					<strong>[필수] 모달 유무(모달일 경우 바닥에 까는 레이어 추가)</strong>
				</td>
			</tr>
			<tr>
				<th>posX</th>
				<th>String</th>
				<td>
					toolTip box의 위치(target:button_id의 left 15추가/null:center)
				</td>
			</tr>
			<tr>
				<th>posY</th>
				<th>String</th>
				<td>
					toolTip box의 위치(target:button_id의 top 15추가/null:center)
				</td>
			</tr>
			<tr>
				<th>pReSize</th>
				<th>Boolean</th>
				<td>
					<strong>[필수] 리사이즈 이벤트 유무</strong>
				</td>
			</tr>
			<tr>
				<th>objectType</th>
				<th>Boolean</th>
				<td>
					objectType이 UA일 시 div태그 style에 padding:30px 추가
				</td>
			</tr>
		</table>
		<!-- Common.open 종료 -->
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/Common.js</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>
	
	<div id="Input" class="mt15">
		<div class="section_title mb10">coviInput <span class="subTitle">[입력창]</span></div>
		
		<div class="topbar_grid mt10">
			<div>input 태그에 속성을 부여하고  coviInput객체의 함수들을 이용해서 axisj의 다양한 Input UI컴포넌트를 사용할 수 있습니다. </div><br>
			1. jquery를 페이지에 추가(의존성) - 없는경우 진행<br>
			2. axisj를 페이지에 추가(의존성) - 없는경우 진행<br>
			3. AXJ.min.css를 페이지에 추가 - 없는경우 진행<br>
			4. 입력창이 그려질  Input 태그 추가. mode/kind 부여<br>
			<div style="color:red">※ mode는 입력의 형식을 바꾸는 속성이고, kind는 입력의 방식을 바꾸는 속성입니다.</div><br>
			<div>[소스예시]</div>
			<div class="source_exp">
   				<xmp><input id="SampleInputBox_M" mode="phone"></xmp>
   				<xmp><input id="SampleInputBox_M" mode="datetime-ymd"></xmp>
   				<xmp><input id="SampleInputBox_M" mode="numberint" max_length="7"></xmp>
   				<xmp><input id="SampleInputBox_K" kind="number" class="AXInput W100" num_min="1" num_max="999" data-axbind="number"></xmp>
   				<xmp><input id="SampleInputBox_K" kind="dictionary" class="AXInput W100" data-axbind="twinSlider"></xmp>
			</div>
		</div>
		
		<div class="mb5"><b>- Attribute Mode</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="15%"/>
				<col width="20%"/>
				<col width="30%"/>
				<col width="35%"/>
			</colgroup>
			<tr>
				<th>money</th>
				<td>
					통화(소수점 포함)<br>
				</td>
				<td>
					[사용 가능 속성]<br>
					allow_minus : 음수 허용 여부<br>
					max_round : 최대 통화 길이 수<br>
					max_length : 최소 통화 길이 수<br>
				</td>
				<td>
					[예시] allow_minus : true, max_round : 3, max_length : 10
				</td>
			</tr>
			<tr>
				<th>moneyint</th>
				<td>
					통화(소수점 포함 안함)<br>
				</td>
				<td>
					[사용 가능 속성]<br>
					maxLength : 최대 통화 길이 수
				</td>
				<td>
					[예시] maxLength: 7
				</td>
			</tr>
			<tr>
				<th>number</th>
				<td>
					숫자(소수점 포함)<br>
				</td>
				<td>
					[사용 가능 속성] <br>
					allow_minus : 음수 허용 여부<br>
					max_length : 최대 숫자 길이 수 <br>
					max_round : 최소 숫자 길이 수
				</td>
				<td>
					[예시] allow_minus : true, max_length : 10, max_round : 5
				</td>
			</tr>
			<tr>
				<th>numberint</th>
				<td>
					숫자(소수점 포함 안함)<br>
				</td>
				<td>
					[사용 가능 속성] <br>
					max_length : 최대 숫자 길이 수
				</td>
				<td>
					[예시] max_length: 7
				</td>
			</tr>
			<tr>
				<th>date</th>
				<td>
					날짜
				</td>
				<td>
					[사용 가능 속성 없음] 
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<th>date-ymd</th>
				<td>
					날짜 + 시간
				</td>
				<td>
					[사용 가능 속성 없음] 
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<th>time</th>
				<td>
					시간
				</td>
				<td>
					[사용 가능 속성 없음] 
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<th>date-slash</th>
				<td>
					닐찌(구분값 /)
				</td>
				<td>
					[사용 가능 속성 없음] 
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<th>datetime-ymd</th>
				<td>
					날짜+시간(년월일)
				</td>
				<td>
					[사용 가능 속성 없음] 
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<th>custom</th>
				<td>
					부분패스워드(특수문자 포함) 및 기타
				</td>
				<td>
					[사용 가능 속성] <br>
					max_length : 최대 커스텀 문자 길이 수 <br>
					patternString : 사용자 지정 커스텀 문자
				</td>
				<td>
					[예시] max_length : 14, patternString : "999999-9999999"
				</td>
			</tr>
			<tr>
				<th>bizno</th>
				<td>
					사업자번호
				</td>
				<td>
					[사용 가능 속성 없음] 
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<th>phone</th>
				<td>
					전화번호
				</td>
				<td>
					[사용 가능 속성 없음]
				</td>
				<td>
				</td>
			</tr>
		</table>
		
		<div class="mb5 mt10"><b>- Attribute Kind</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="10%"/>
				<col width="15%"/>
				<col width="40%"/>
				<col width="35%"/>
			</colgroup>
			<tr>
				<th>number</th>
				<td>
					숫자 입력 바인딩<br>(스피너 포함)
				</td>
				<td>
					[사용 가능 속성]<br>
					num_max : 최대값 <br>
					num_min : 최소값 
				</td>
				<td>
					[예시] num_max : 1, num_min : 100
				</td>
			</tr>
			<tr>
				<th>money</th>
				<td>
					통화 입력 바인딩
				</td>
				<td>
					[사용 가능 속성]<br>
					money_max : 최대값 
					money_min : 최소값
				</td>
				<td>
					[예시] money_max : 1, money_min : 100
				</td>
			</tr>
			<tr>
				<th>switch</th>
				<td>
					스위치 바인딩
				</td>
				<td>
					[사용 가능 속성] <br>
					off_value : 스위치 off 지정 값 <br>
					on_value : 스위치 on 지정 값<br>
					readonly_Fg : 읽기전용 스위치 여부
				</td>
				<td>
					[예시] off_value : "AM", on_value : "PM", readonly_Fg : true
				</td>
			</tr>
			<tr>
				<th>slider</th>
				<td>
					기본 슬라이더 바인딩
				</td>
				<td>
					[사용 가능 속성] <br>
					slider_min : 슬라이더 최소 값 <br>
					slider_max : 슬라이더 최대 값 <br>
					snap : 슬라이드 이동 속도<br>
					unit : 값 뒤에 붙여 표현하는 단위
				</td>
				<td>
					[예시] slider_min : 0, slider_max : 100, snap : 100,<br> unit : "%"
				</td>
			</tr>
			<tr>
				<th>twinslider</th>
				<td>
					이중슬라이더 바인딩
				</td>
				<td>
					[사용 가능 속성] <br>
					twslider_min : 최소값<br>
					twslider_max : 최대값<br>
					snap : 스크롤이 이동하는 단위<br>
					unit : 값 뒤에 붙여 표현하는 단위<br>
					separator : 두개의 값 사이를 구분 지을 문자열
				</td>
				<td>
					[예시] twslider_min : 0, twslider_max : 100, snap : 100, unit : "%", separator : "~"
				</td>
			</tr>
			<tr>
				<th>dictionary</th>
				<td>
					다국어 팝업 창 바인딩
				</td>
				<td>
					[사용 가능 속성]<br>
					dic_src : 다국어 팝업을 호출할 때 url에 포함되는 initData<br>
					dic_callback : 다국어 팝업을 호출할 때 url에 포함되는 콜백 함수<br>
					id : 다국어 팝업을 호출할 때 url에 포함되는 다국어 아이디(dicID)<br>
					src_elem : kind가 dictionaryBtn알 경우 trigger로 click이벤트 발생
				</td>
				<td>
 			</td>
			</tr>
			<tr>
				<th>date</th>
				<td>
					달력 입력창 바인딩
				</td>
				<td>
					[사용 가능 속성] <br>
					date_align : 달력에서 input text 의 위치<br>
					date_valign : 달력에서 input text 의 위치<br>
					date_separator : 날짜형식 표시 구분 문자열<br>
					date_selectType : ("y"|"m"|"d") 날짜선택범위 y 를 지정하면 년도만 선택<br>
					date_defaultSelectType : 달력컨트롤의 년월일 선택도구 중에 먼저 보이는 도구타입<br>
					defaultDate : 날짜 형식의 문자열로 빈값의 달력 기준일을 설정<br>
					minDate : 날짜 형식의 문자열로 선택할 수 있는 최소일<br>
					maxDate : 날짜 형식의 문자열로 선택할 수 있는 최대일<br>
					onBeforeShowDay : 날짜를 보여주기 전에 호출하는 함수.<br>
					vali_early : 시작일을 종료일 이전으로 선택 되도록 하는 조건 여부<br>
					vali_late : 종료일을 시작일 이후로 선택되도록 하는 조건 여부<br>
					vali_date_id : vali_early, vali_late조건이 적용될 element id
				</td>
				<td>
					[예시] date_align : "right", date_valign : "top", date_separator : "-",<br>
					date_selectType : "d", date_defaultSelectType : "d", defaultDate : "",<br>
					minDate : "", maxDate : "", onBeforeShowDay : {}<br>
					vali_early : true, vali_date_id "test-id": , vali_late : false
				</td>
			</tr>
		</table>
		
		<div class="section_title mb10 mt65 ">coviInput.init <span class="subTitle">[입력창 세팅]</span></div>
		<!-- coviInput.init 시작 -->
		<div class="topbar_grid mt10">
			Input태그의 속성(mode/kind)에 따라 다양한 데이터 작성 제어가 가능한 컨트롤을 제공합니다.<br>
			사용자가 원하는 Input태그의 속성 정의 후 coviInput.init()함수를 실행시키면 Input의 형태가 변화합니다.<br>
		
			<div style="margin-top:10px">※ input attribute mode(형식) 종류의 따른 변화 값 테스트 입니다.</div>
			<div>
				<select id="sampleInputModeType" class="AXSelect" style="border: 1px solid #d6d6d6;">
					<option value="" selected>입력창 모드 타입(input mode type)</option>
					<option value="money">money [통화(소수점 포함, allow_minus:true, max_round:3, max_length:10)]</option>
					<option value="moneyint">moneyint [통화(소수점 포함 안함, maxLength: 7)]</option>
					<option value="number">number [숫자(소수점 포함, allow_minus: true, max_length: 10, max_round: 5)]</option>
					<option value="numberint">numberint [숫자(소수점 포함 안함, maxLength: 7)]</option>
					<option value="date">date [날짜]</option>
					<option value="date-ymd">date-ymd [날짜+시간]</option>
					<option value="time">time [시간]</option>
					<option value="date-slash">date-slash [날짜(/)]</option>
					<option value="datetime-ymd">datetime-ymd [날짜+시간(년월일)]</option>
					<option value="custom">custom [숫자 및 특수기호]</option>
					<option value="bizno">bizno [사업자번호]</option>
					<option value="phone">phone [전화번호]</option>
				</select>
				<input id="SampleInputBox_M" mode="" class="selectType02 size102" style="height:25px; width:200px"> </input>
			</div>
			
			<div style="margin-top:10px">※ input attribute kind(형태) 종류의 따른 변화 값 테스트 입니다.</div>
			<div>
				<select id="sampleInputKindType" class="AXSelect" style="border: 1px solid #d6d6d6;">
					<option value="" selected>입력창 종류 타입(input kine type)</option>
					<option value="number">setNumber()</option>
					<option value="money">setMoney()</option>
					<option value="switch">setSwitch(pReadOnly)</option>
					<option value="slider">setSlider()</option>
					<option value="twinslider">setTwinSlider()</option>
					<option value="dictionary">setDictionary()</option>
					<option value="date">setDate()</option>
				</select>
				<input id="SampleInputBox_K" kind="" class="AXInput W100"> </input>
				<div id="SmpleInbutBox_K_info" ></div>
			</div>
		</div>
		
		<div class="mb5"><b>- init함수 실행 시 호출되는 Method</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="15%;"/>
				<col width="35%"/>
				<col width="50%"/>
			</colgroup>
			<tr>
				<th>setInputPattern()</th>
				<td>
					input text 엘리먼트에 mode속성에 따른 형식을 바인딩합니다.
					<ul style="margin-left: 20px;">
						<li>coviInput.setNumber()</li>
					</ul>
				</td>
				<td>
			 		 [allow_minus] - 음수 허용 여부 (optional)<br>
   					 [max_length] - 최대 자릿수 (optional)<br>
   					 [max_round] - 반올림 자릿수 (optional)<br>
   					 [num_max] - 최대값 (optional)<br>
   					 [num_min] - 최소값 (optional)<br>
   					 [patternString] - 커스텀 스트링 기준값 (optional)<br>
				</td>
			</tr>
			<tr>
				<th>setNumber()</th>
				<td>
					input text 엘리먼트에 숫자 컨트롤을 바인딩 합니다.
					<ul style="margin-left: 20px;">
						<li>coviInput.setNumber()</li>
					</ul>
				</td>
				<td>
				 	[num_max] - 최소값 (optional)<br>
    				[num_min] - 최대값 (optional)<br>
				</td>
			</tr>
			<tr>
				<th>setMoney()</th>
				<td>
					input text 엘리먼트에 통화단위가 입력 되도록 합니다.
					<ul style="margin-left: 20px;">
						<li>coviInput.setMoney()</li>
					</ul>
				</td>
				<td>
					[money_max] - 최소값 (optional)<br>
   					[money_min] - 최대값 (optional)<br>
				</td>
			</tr>
			<tr>
				<th>setSwitch()</th>
				<td>
					input text 엘리먼트에 스위치 컨트롤을 적용합니다.
					<ul style="margin-left: 20px;">
						<li>coviInput.setSwitch()</li>
					</ul>
				</td>
				<td>
					[off_value] - switch off value<br>
   					[on_value] - switch on value<br>	
				</td>
			</tr>
			<tr>
				<th>setSlider()</th>
				<td>
					input text 엘리먼트에 slider 컨트롤을 바인딩 합니다.
					<ul style="margin-left: 20px;">
						<li>coviInput.setSlider()</li>
					</ul>
				</td>
				<td>
					[slider_min] - 최소값 (optional)<br>
   					[slider_max] - 최대값 (optional)<br>
   					[snap] - 스크롤이 이동하는 단위<br>
   					[unit] - 값 뒤에 붙여 표현하는 단위 (optional)<br>
				</td>
			</tr>
			<tr>
				<th>setTwinSlider()</th>
				<td>
					input text 엘리먼트에 번위 선택이 가능한 slider 컨트롤을 바인딩 합니다.
					<ul style="margin-left: 20px;">
						<li>coviInput.setTwinSlider()</li>
					</ul>
				</td>
				<td>
					[twslider_min] - 최소값 (optional)<br>
   					[twslider_max] - 최대값 (optional)<br>
   					[snap] - 스크롤이 이동하는 단위<br>
   					[unit] - 값 뒤에 붙여 표현하는 단위 (optional)<br>
   					[separator] -두개의 값 사이를 구분 지을 문자열<br>
				</td>
			</tr>
			<tr>
				<th>setDate()</th>
				<td>
					input text 엘리먼트에 날짜 컨트롤을 바인딩 합니다.
					<ul style="margin-left: 20px;">
						<li>coviInput.setDate()</li>
					</ul>
				</td>
				<td>
					[date_align] - ("left"|"center"|"right") 달력에서 input text 의 위치<br>
				    [date_valign] - ("top"|"middle"|"bottom") 달력에서 input text 의 위치<br>
				    [date_separator] - 날짜형식 표시 구분 문자열<br>
				    [date_selectType] - ("y"|"m"|"d") 날짜선택범위 y 를 지정하면 년도만 선택됩니다.<br>
				    [date_defaultSelectType] -  ("y"|"m"|"d") 달력컨트롤의 년월일 선택도구 중에 먼저 보이는 도구타입<br>
				    [defaultDate] - ("yyyy[separator]mm[separator]dd") 날짜 형식의 문자열로 빈값의 달력 기준일을 설정합니다. 지정하지 않으면 시스템달력의 오늘을 기준으로 합니다.<br>
				    [minDate] - ("yyyy[separator]mm[separator]dd") 날짜 형식의 문자열로 선택할 수 있는 최소일을 설정합니다.<br>
				    [maxDate] - ("yyyy[separator]mm[separator]dd") 날짜 형식의 문자열로 선택할 수 있는 최대일을 설정합니다.<br>
				    [onBeforeShowDay] - 날짜를 보여주기 전에 호출하는 함수. date를 파라미터로 받으며 다음과 같은 형식의 Object를 반환해야 한다. { isEnable: true|false, title:'성탄절', className: 'holyday', style: 'color:red' }
				</td>
			</tr>
			<tr>
				<th>setDictionary()</th>
				<td>
					input text 엘리먼트에 다국어 설정 팝업이 호출될 수 있도록 바인딩 합니다.
					<ul style="margin-left: 20px;">
						<li>coviInput.setDictionary()</li>
					</ul>           
				</td>
				<td>
				</td>
			</tr>
		</table>
		<!-- coviInput.init 종료 -->
		
		<div class="mb5 mt65"><b>- Method</b></div>
		<div style="color:red; font-size: 12px;">※ init함수에서 실행되지 않는 메서드들의 모음입니다.</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>setSegment</th>
				<td>
					input text 엘리먼트에 segment 컨트롤을 바인딩
					<div class="source_exp">coviInput.setSegment(id, option);</div>
				</td>
			</tr>
			<tr>
				<th>setCssSegment</th>
				<td>
					input text 엘리먼트에 css와 segment 컨트롤을 바인딩
					<div class="source_exp">coviInput.setCssSegment(id, theme_name, option, css_name);</div>
				</td>
			</tr>
			<tr>
				<th>SimpleBindSelector</th>
				<td>
					input text 엘리먼트에 selector 컨트롤을 바인딩
					<div class="source_exp">
						coviInput.SimpleBindSelector(id, appendable, option, positionfixed, direction, finder, finder_onclick);
					</div>
				</td>
			</tr>
			<tr>
				<th>AjaxBindSelector</th>
				<td>
					input text 엘리먼트에 ajax 데이터 호출 방법을 사용하여 selector 컨트롤을 바인딩
					<div class="source_exp">
						coviInput.AjaxBindSelector(id, appendable, positionfixed, direction, url, param);
					</div>
				</td>
			</tr>
			<tr>
				<th>MultiSelector</th>
				<td>
					select 엘리먼트에 config를 할당
					<div class="source_exp">
						coviInput.MultiSelector(id, options);
					</div>
				</td>
			</tr>
			<tr>
				<th>UserBindSelector</th>
				<td>
					input text 엘리먼트에 selector 컨트롤을 바인딩 합니다.(expandBox 방향지정, option외 입력값 가능 여부, expandBox option css fixed 여부 지정가능)
					<div class="source_exp">
						coviInput.UserBindSelector(id, appendable, positionfixed, direction, optionvalue, optiontext, option);
					</div>
				</td>
			</tr>
			<tr>
				<th>SimpleBindTagSelector</th>
				<td>
					바인드 된 옵션 데이터 중에서 한개이상의 아이템을 Input의 값으로 담아서 선택
					<div class="source_exp">
						coviInput.SimpleBindTagSelector(id, option, appendable, direction, selectorWidth, optionValue_hname, optionText_hname);
					</div>           
				</td>
			</tr>
			<tr>
				<th>AjaxBindTagSelector</th>
				<td>
					ajax를 통해 바인드 된 옵션 데이터 중에서 한개이상의 아이템을 Input의 값으로 담아서 선택
					<div class="source_exp">
						coviInput.AjaxBindTagSelector(id, appendable, direction, url, param);
					</div>
				</td>
			</tr>
			<tr>
				<th>UserBindTagSelector</th>
				<td>
					바인드 된 옵션 데이터 중에서 한개이상의 아이템을 Input의 값으로 담아서 선택(value, text를 사용자가 지정가능)
					<div class="source_exp">
						coviInput.UserBindTagSelector(id, option, appendable, direction, selectorWidth, optionValue_hname, optionText_hname, optionvalue, optiontext);
					</div>
				</td>
			</tr>
			<tr>
				<th>setValidator</th>
				<td>
					선언된 AXValidator 클래스를 사용하기 위해 속성을 정의
					<div class="source_exp">
						coviInput.setValidator(formname, required_msg);
					</div>
				</td>
			</tr>
			<tr>
				<th>makeFocus</th>
				<td>
					IE Input Focus Error 임시 대응 코드
					<div class="source_exp">
						coviInput.makeFocus();
					</div>
				</td>
			</tr>
		</table>
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/java/egovframework/core/web/CommentCon.java</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.groupware/src/main/webapp/resource/script/user/board.js</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>
	
	<div id="Etc" class="mt15">
		<!-- Common.toolTip 시작 -->
		<div class="section_title mb10">Common.toolTip <span class="subTitle">[툴팁 컨트롤(다국어)]</span></div>
		<div class="topbar_grid">
			<div id="sampleRenderColorPickerDiv"></div>
			<div>
			해당 요소에 마우스를 올리면 추가적인 정보가 나타납니다.
			</div>
			<div>
				<input type="button" class="btnTypeDefault help_ico" style="margin-bottom:2px;" value="마우스를 올리세요">
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable" style="margin-bottom:10px">
			<colgroup>
				<col width="150px;"/>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>targetObj</th>
				<th>Object</th>
				<td><strong>[필수] ToolTip이 그려질 태그의 ID </strong></td>
			</tr>
			<tr>
				<th>codeArr</th>
				<th>String</th>
				<td>
					<strong>[필수] toolTip box Text 다국어를 지정하는 값으로 빈 값일 때는 현재 다국어 값</strong>
				</td>
			</tr>
			<tr>
				<th>opt</th>
				<th>String</th>
				<td>
					toolTip box에 적용되는 스타일 요소
				</td>
			</tr>
		</table>
		<b>- 다국어 생성</b>
		<div class="topbar_grid mt10">
			<ul style="padding-left: 20px; list-style: decimal;">
				<li>
					<div>codeArr parameter를 활용하여 툴팁의 제목, 예시, 내용의 다국어 정보를 생성합니다.</div>
					<ul>[key]_tit : 툴팁 제목</ul>
					<ul>[key]_ex : 툴팁 예시</ul>
					<ul>[key]_cont : 툴팁 내용</ul>
				</li>
			</ul>
		</div>
		<!-- Common.toolTip 종료 -->
	
		<!-- FlowerName -->
		<div class="section_title mb10" style="margin-top:40px">coviCtrl.setFlowerName <span class="subTitle">[FlowerName(프로필조회)]</span></div>
		<div class="topbar_grid">
			<div id="sampleRenderColorPickerDiv"></div>
			<div>
			사용자 이름 클릭 시 프리젠스가 나타나게 됩니다.
			</div>
			<div>
				<strong class="btnFlowerName btnTypeDefault" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer;" data-user-code="superadmin" data-user-mail="" >테스트 대상</strong>
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable" style="margin-bottom:10px">
			<colgroup>
				<col width="150px;"/>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>target</th>
				<th>String</th>
				<td>대상 태그 id의 값</td>
			</tr>
		</div>
		</table>
		<b>- 사용법</b>
		<div class="topbar_grid mt10">
			<ul style="padding-left: 20px; list-style: decimal;">
				<li>
					<div>적용하려는 대상 HTML 태그가 동적으로 생성하는 경우</div>
					<ul>a. onclick="coviCtrl.setFlowerName(this)"</ul>
					<ul>b. class="btnFlowerName"</ul>
					<ul>c. style="position:relative;cursor:pointer;"  (프리젠스 UI가 대상 요소 하단에 생성되기 위해)</ul>
					<ul>d. data-user-code= 대상 UR_Code(필수)</ul>
					<ul>e. data-user-mail= 대상 MailAdress(필수X)</ul>
				</li>
				<li>
					<div>적용하려는 대상 HTML 태그가 정적으로 생성되어 있고 동적으로 값을 넣고 있는 경우</div>
					<ul>a. $("#대상 태그 ID").css("position","relative"); (프리젠스 UI가 대상 요소 하단에 생성되기 위해)</ul>
					<ul>b. $("#대상 태그 ID").attr("onclick","coviCtrl.setFlowerName(this)");</ul>
					<ul>c. $("#대상 태그 ID").attr({"data-user-code": 대상 UR_Code, "data-user-mail":대상 MailAdress});</ul>
					<ul>d. $("#대상 태그 ID").addClass("btnFlowerName");</ul>
				</li>
			</ul>
		</div>
		<!-- FlowerName종료 -->
		
		<!-- tree -->
		<div class="section_title mb10" style="margin-top:40px">coviTree <span class="subTitle">[트리 컨트롤]</span></div>
		<div class="topbar_grid">
			<div id="sampleRenderColorPickerDiv"></div>
			<div>
			트리 그리드 생성
			</div>
		</div>
		<div class="mb5"><b>- Parameter</b></div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>pid</th>
				<th>String</th>
				<td><strong>[필수] 대상 태그 id의 값</strong></td>
			</tr>
			<tr>
				<th>data</th>
				<th>String</th>
				<td><strong>[필수] tree data정보</strong></td>
			</tr>
			<tr>
				<th>nodeName</th>
				<th>String</th>
				<td><strong>[필수] data parameter에서 title node명</strong></td>
			</tr>
			<tr>
				<th>col_width</th>
				<th>String</th>
				<td><strong>[필수] tree width</strong></td>
			</tr>
			<tr>
				<th>col_align</th>
				<th>String</th>
				<td><strong>[필수] tree align</strong></td>
			</tr>
			<tr>
				<th>IsCheck</th>
				<th>Boolean</th>
				<td>tree list의 checkbox 여부</td>
			</tr>
			<tr>
				<th>IsRadio</th>
				<th>Boolean</th>
				<td>tree list의 radiobox 여부</td>
			</tr>
		</div>
		</table>
		<!-- tree종료 -->
		
		<div class="section_title mt65 mb10">참고사항</div>
		<table class="AXFormTable">
			<colgroup>
				<col width="150px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th>컨트롤 구현 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/Common.js</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/covision.control.js</li>
						<li>/smarts4j.covicore/src/main/webapp/resources/script/Controls/coviTree.js</li>
					</ul>
				</td>
			</tr>
			<tr>
				<th>상단 예제 관련 주요파일</th>
				<td>
					<ul style="margin-left: 20px;">
						<li>/smarts4j.covicore/src/main/webapp/WEB-INF/views/core/devhelper/CommonControl.jsp</li>
					</ul>
				</td>
			</tr>
		</table>
	</div>	
</div>

<script type="text/javascript">
	//# sourceURL=CommonControl.jsp
	
	//toolTip
	Common.toolTip($(".btnTypeDefault"), "collabProject1", "width:310px; margin-top:120px;");
	
	function openFunction(){
		Common.open("", "commentPopup", "테스트 팝업", "/groupware/board/goCommentPopup.do?mode=" , "300px", "230px", "iframe", true, null, null, true);
	}
	initContent();

	function initContent() {
		clickTab($("#aSelectPage"));
	}

	function clickTab(pObj) {
		$(".AXTab").attr("class", "AXTab");
		$(pObj).addClass("AXTab on");

		var isLoad = $(pObj).attr("isLoad");
		var str = $(pObj).attr("value");
		
		$(".AXTab").each(function() {
			if ($(this).attr("class") == "AXTab on") {
				$("#" + $(this).attr("value")).show();
			} else {
				$("#" + $(this).attr("value")).hide();
			}
		});
		
		if(isLoad == undefined){
			switch(str.toUpperCase()){
				case "SELECT": 
					setSelect();
					break;
				case "FILE": 
					setFile();
					break;
				case "COMMENTS": 
					//setComment();
					break;
				case "CALENDAR": 
					setCalendar();
					coviInput.setDate();
					break;
				case "AUTOCOMPLETE": 
					setAutoComplete();
					break;
				case "PICKER": 
					setPicker();
					break;
				case "ORGCHART": 
					setOrgChart();
					break;
				case "EDITOR": 
					setEditor();
					break;
				case "CALENDARVIEW": 
					setCoviCalendar();
					break;
				case "BOARD":
					setBoard();
					break;
			}
			
			$(pObj).attr("isLoad", "Y");
		}

	}
	
	
	
	
	
	function setSelect(){
		// renderAjaxSelect 바인딩
		var initInfos = [
	   		{
		   		target : 'sampleRenderAjaxDiv',				// [필수] select가 그려질 위치의 div 태그의  ID
		   		codeGroup : 'BizSection',					// [필수] 기초코드의 코드그룹 값 
		   		hasGroupCode : "N",							// 코드그룹과 코드가 동일한 항목 표시여부 (Y[default]/N)
		   		defaultVal : 'BizSection',					// 바인딩 후 기본 값  
		   		width : '100',								// 가로 길이 (지정하지 않을 경우 별도  width 값 지정되지 않음)
		   		onchange : 'changeRenderAjax'				// 값 변경 시 호출될 함수 (호출 시 매개변수 없음)
	   		}
	   	];
		coviCtrl.renderAjaxSelect(initInfos, "completeRenderAjax", Common.getSession("lang"));
		
		
		// renderDomainAXSelect 바인딩
		coviCtrl.renderDomainAXSelect('sampleRenderDomainAXDiv', Common.getSession("lang"), 'changeRenderDomainAX', 'completeRenderDomainAX', "",false, {codeType: "CODE"});

		// renderCompanyAXSelect 바인딩 
		coviCtrl.renderCompanyAXSelect("sampleRenderCompanyAXDiv", Common.getSession("lang"), false, "", "", '');

		// renderAXSelect 바인딩
		coviCtrl.renderAXSelect("BizSection,DicSection",
				"sampleRenderAXDiv1,sampleRenderAXDiv2", Common
						.getSession("lang"), "", "", "");
	}
	//초기화
	function reSelect(selector) {
		var initInfos = [ {
			target : 'sampleRenderAjaxDiv', // [필수] select가 그려질 위치의 div 태그의  ID
			codeGroup : 'BizSection', // [필수] 기초코드의 코드그룹 값 
			hasGroupCode : "N", // 코드그룹과 코드가 동일한 항목 표시여부 (Y[default]/N)
			defaultVal : 'BizSection', // 바인딩 후 기본 값  
			width : '100', // 가로 길이 (지정하지 않을 경우 별도  width 값 지정되지 않음)
			onchange : 'changeRenderAjax' // 값 변경 시 호출될 함수 (호출 시 매개변수 없음)
		} ];
		switch (selector) {
		case 'Ajax':
			coviCtrl.renderAjaxSelect(initInfos, "completeRenderAjax", Common.getSession("lang"));
			break;
		case 'Domain':
			coviCtrl.renderDomainAXSelect('sampleRenderDomainAXDiv', Common.getSession("lang"), '', '', "", false, {codeType : "CODE"});
			break;
		case 'Company':
			coviCtrl.renderCompanyAXSelect("sampleRenderCompanyAXDiv", Common.getSession("lang"));
			break;
		case 'Ax':
			coviCtrl.renderAXSelect("BizSection,DicSection",
					"sampleRenderAXDiv1,sampleRenderAXDiv2", Common.getSession("lang"), "", "", "");
		default:
			return true;
		}
	}

	// renderAjaxSelect 관련 함수 시작
	function getRenderAjax() {
		alert("text: " + coviCtrl.getSelected('sampleRenderAjaxDiv').text
				+ ", value: " + coviCtrl.getSelected('sampleRenderAjaxDiv').val);
	}
	function changeRenderAjax() {
		coviCmn
				.traceLog("renderAjaxSelect 값 변경 \n" + "text: "
						+ coviCtrl.getSelected('sampleRenderAjaxDiv').text
						+ ", value: "
						+ coviCtrl.getSelected('sampleRenderAjaxDiv').val);
	}
	function completeRenderAjax() {
		coviCmn.traceLog("renderAjaxSelect 바인딩 완료");
	}
	// renderAjaxSelect 관련 함수 종료

	
	
	// renderDomainAXSelect 관련 함수 시작
	function getRenderDomainAX() {
		alert("text: " + $("#sampleRenderDomainAXDiv option:selected").text()
				+ ", value: " + $("#sampleRenderDomainAXDiv").val());
	}
	function changeRenderDomainAX(obj) {
		coviCmn.traceLog("renderDomainAXSelect 값 변경 \n" + "text: "
				+ obj.optionText + ", value: " + obj.optionValue);
	}
	function completeRenderDomainAX() {
		coviCmn.traceLog("renderDomainAXSelect 바인딩 완료");
	}
	//hasAll - parameter
	function getHasAll(param) {
		if(param == "Domain"){
			coviCtrl.renderDomainAXSelect('sampleRenderDomainAXDiv', Common.getSession("lang"), 'changeRenderDomainAX','completeRenderDomainAX', "", true, {codeType : "CODE"});
		}else if(param == "Company"){
			coviCtrl.renderCompanyAXSelect("sampleRenderCompanyAXDiv", Common.getSession("lang"), true, "", "", "");
		}
	}
	//options - parameter
	function getOptionValue(param) {
		if(param == "Domain"){
			coviCtrl.renderDomainAXSelect('sampleRenderDomainAXDiv', Common.getSession("lang"), 'changeRenderDomainAX','completeRenderDomainAX', "", true);
		}else if(param == "Company"){
			coviCtrl.renderCompanyAXSelect("sampleRenderCompanyAXDiv", Common.getSession("lang"), true, "", "", "", {codeType : "ID"});
		}
	}
	// renderDomainAXSelect 관련 함수 종료

	
	
	// renderCompanyAXSelect 관련 함수 시작
	function getRenderCompanyAX() {
		alert("text: " + $("#sampleRenderCompanyAXDiv option:selected").text()
				+ ", value: " + $("#sampleRenderCompanyAXDiv").val());
	}
	// renderCompanyAXSelect 관련 함수 종료

	
	
	// renderAXSelect 관련 함수 시작
	function getRenderAX(number) {
		alert("text: " + $("#sampleRenderAXDiv" + number + " option:selected").text()
				+ ", value: " + $("#sampleRenderAXDiv" + number).val());
	}
	// renderAXSelect 관련 함수 종료

	
	
	
	
	function setFile() {
		//renderFileControlEx1 바인딩
		coviFile.renderFileControl('sampleRenderFileControlEx1', {
			listStyle : 'table', // [필수] table 또는 div (파일컨트롤 내 row가 table tag로 구성될지 div 태그로 구성될지 여부로 디자인 차이는 없음)
			actionButton : 'add', /* [필수] 표시될 버튼으로  add(추가)와 upload(등록)가 있고 구분자는 , 이다. 
											   upload 버튼 사용 시 Front로 업로드 되며 Front에서 Back으로 이동시키거나 바로 Back으로 업로드하는 처리는 각 모듈별로 서버 단에서 공통 함수를 사용해야 한다.*/
			image : false, // true일 경우 이미지만 업로드 가능 (true/false[default])
			multiple : true, // 1개 이상의 파일 첨부 허용 여부 (true[default]/false)
			callback : '', // 등록 버튼 클릭하여 Front에 Upload 된 후 호출될 함수명으로 빈값일 경우 별도 호출 없음 
			//servicePath : Common.getBaseConfig("BackStoragePath").replace("{0}", Common.getSession("DN_Code"))+'Devhelper/',					// 등록 버튼 클릭하여 Front에 Upload할 때 Back에 위치한 파일을 합쳐서 처리할 경우 back 경로를 지정하는 값으로 그런 경우가 없다면 지정하지 않아도 무관(sys_storage정보 이용 이후 사용하지 않는 값, 서버에서 file정보로 back경로 조회)
			servicePath : '', // 등록 버튼 클릭하여 Front에 Upload할 때 Back에 위치한 파일을 합쳐서 처리할 경우 back 경로를 지정하는 값으로 그런 경우가 없다면 지정하지 않아도 무관(sys_storage정보 이용 이후 사용하지 않는 값, 서버에서 file정보로 back경로 조회)
			fileSizeLimit: 209715200								// 파일 최대 사이즈로 지정하지 않을 경우 200MB
		});
	}

	
	
	// renderFileControlEx1 관련 함수 시작
	function uploadBackRenderFileControlEx1() {
		if (coviFile.fileInfos.length < 1) {
			Common.Warning("<spring:message code='Cache.msg_FileNotAdded'/>") // 파일이 추가되지 않았습니다.
			return false;
		}

		
		var fileData = new FormData();
		fileData.append("fileInfos", JSON.stringify(coviFile.fileInfos));

		for (var i = 0; i < coviFile.files.length; i++) {
			if (typeof coviFile.files[i] == 'object') {
				fileData.append("files", coviFile.files[i]);
			}
		}

		$.ajax({
					url : "/covicore/devhelper/fileupload/uploadToBack.do", //uploadToBack 샘플 
					data : fileData,
					type : "post",
					dataType : 'json',
					processData : false,
					contentType : false,
					success : function(data) {
						if (data.status = 'SUCCESS') {
					Common.Inform("<spring:message code='Cache.msg_UploadOk'/>\n 상세한 내용은 coviCmn.traceLog 참고 바랍니다.");		//업로드 되었습니다.
					coviCmn.traceLog("renderFileControl 예제1 Back 업로드 완료", data);
						}
					},
					error : function(response, status, error) {
       	    	 CFN_ErrorAjax("/covicore/devhelper/fileupload/uploadToBack.do", response, status, error);
					}
				});
	}
	function getBackRenderFileControlEx1() {
		coviFile.files = []; //물리 파일 삭제
		coviFile.fileInfos = []; //파일 정보 삭제

		if (coviFile.option.listStyle == 'table') {
			$("#sampleRenderFileControlEx1 table.fileHover tbody tr").remove(); //행삭제 
		} else if (coviFile.option.listStyle == 'div') {
			$("#sampleRenderFileControlEx1 div.dvFileItem").remove(); //행삭제 
		}

		if (coviFile.files.length == 0) {
			$('#sampleRenderFileControlEx1 .dragFileBox').show();
		}

		$.ajax({
					type : "POST",
					url : "/covicore/devhelper/fileupload/getBackFileList.do",
					success : function(data) {
						if (data.status = 'SUCCESS') {
							if (data.fileList.length < 1) {
		       			Common.Inform("<spring:message code='Cache.msg_NoDataList'/>");		//조회할 목록이 없습니다.
							}
	       			coviFile.setFile('sampleRenderFileControlEx1', data.fileList); 			// 렌더링 시점에 파라미터로 넘겨 바인딩하는 것도 가능
						}
					},
					error : function(response, status, error) {
       	    	 CFN_ErrorAjax("/covicore/devhelper/fileupload/getBackFileList.do", response, status, error);
					}
				});
	}
	// renderFileControlEx1 관련 함수 종료

	
	
	// renderFileControlEx2 관련 함수 종료
	var g_frontFileInfos = [];
	function uploadFrontRenderFileControlEx2() {
		var url = "";
		url += "/covicore/control/callFileUpload.do?"
		url += "&elemID=sampleRenderFileControlEx2"; // [필수] 파일 업로드 컨트롤이 그려질 div 태그의 ID
		url += "&listStyle=div"; // table[default] 또는 div (파일컨트롤 내 row가 table tag로 구성될지 div 태그로 구성될지 여부로 디자인 차이는 없음)
		url += "&callback=callBackRenderFileControlEx2"; // 등록 버튼 클릭하여 Front에 Upload 된 후 호출될 함수명으로 빈값일 경우 별도 호출 없음 
		//url += "&servicePath="+Common.getBaseConfig("BackStoragePath").replace("{0}", Common.getSession("DN_Code"))+"Devhelper/";			// 등록 버튼 클릭하여 Front에 Upload할 때 Back에 위차한 파일을 합쳐서 처리할 경우 back 경로를 지정하는 값으로 그런 경우가 없다면 지정하지 않아도 무관(sys_storage정보 이용 이후 사용하지 않는 값, 서버에서 file정보로 back경로 조회)
		url += "&servicePath="; // 등록 버튼 클릭하여 Front에 Upload할 때 Back에 위차한 파일을 합쳐서 처리할 경우 back 경로를 지정하는 값으로 그런 경우가 없다면 지정하지 않아도 무관(sys_storage정보 이용 이후 사용하지 않는 값, 서버에서 file정보로 back경로 조회)
		url += "&image=true"; // true일 경우 이미지만 업로드 가능 (true/false[default])
		url += "&actionButton=" + encodeURIComponent("add,upload"); /* 표시될 버튼으로  add(추가)와 upload(등록)가 있고 구분자는 , 이며 기본값은 add이다.
													upload 버튼 사용 시 Front로 업로드 되며 Front에서 Back으로 이동시키거나 바로 Back으로 업로드하는 처리는 각 모듈별로 서버 단에서 공통 함수를 사용해야 한다.*/
		//url += "&multiple=true";								// 1개 이상의 파일 첨부 허용 여부 (true[default]/false)
		//url += "&fileSizeLimit=209715200";					// 파일 최대 사이즈로 지정하지 않을 경우 200MB

		Common.open("", "popupRenderFileControlEx2", "coviFile.renderFileControl 예제2", url, "500px", "250px", "iframe", true, null, null, true);

	}
	function callBackRenderFileControlEx2(resultObj, targetID) {
		g_frontFileInfos = resultObj;

		var sHtml = "";
		$(resultObj).each(function(idx,data) {
			var thumbName = data.SavedName.substr(0, data.SavedName.lastIndexOf('.')) + '_thumb.jpg';
			var srcPath = Common.getBaseConfig("FrontStorage").replace("{0}", Common.getSession("DN_Code")) + "/" + thumbName;
			sHtml += '<img src="' + srcPath + '" onerror="coviCmn.imgError(this)" style="width: 100px; height:100px; overflow:hidden; ' + (idx > 0 ? "margin-left:10px;" : "" ) + '"/>';
						});

		$("#imgRenderFileControlEx2").html(sHtml);

		coviCmn.traceLog("renderFileControl 예제2 Front 업로드 완료", resultObj);
		Common.close("popupRenderFileControlEx2");
		Common.Inform("<spring:message code='Cache.msg_UploadOk'/>\n 상세한 내용은 coviCmn.traceLog 참고 바랍니다.");		//업로드 되었습니다.
	}
	function moveToBackRenderFileControlEx2() {

		if (g_frontFileInfos.length < 1) {
			Common.Warning("<spring:message code='Cache.msg_FileNotAdded'/>") // 파일이 추가되지 않았습니다.
			return false;
		}

		
		var sampleData = new FormData();
		sampleData.append("frontFileInfos", JSON.stringify(g_frontFileInfos));

		$.ajax({
					type : "POST",
					dataType : "json",
					data : sampleData,
					url : "/covicore/devhelper/fileupload/moveToBack.do",
					processData : false,
					contentType : false,
					success : function(data) {
						if (data.status = 'SUCCESS') {
							g_frontFileInfos = [];
					$("#imgRenderFileControlEx2").html('<img src="" onerror= "coviCmn.imgError(this)" style="width: 100px; height:100px; overflow:hidden "/>');
					Common.Inform("<spring:message code='Cache.msg_task_completeMove'/>\n 상세한 내용은 coviCmn.traceLog 참고 바랍니다.")
					coviCmn.traceLog("renderFileControl 예제2 Front → Back 이동 완료", data);
						}
					},
					error : function(response, status, error) {
      	    	 CFN_ErrorAjax("/covicore/devhelper/fileupload/moveToBack.do", response, status, error);
					}
				});
	}
	// renderFileControlEx2 관련 함수 종료 

	
	
		
	
	//coviComment.load 관련 함수 시작
	function popupCoviCommentLoad() {
		Common.open("", "popupCoviCommentLoad", "coviComment.load 예제", "/covicore/devhelper/PopupComment.do", "800px", "450px", "iframe", true, null, null, true);
	}
	//coviComment.load 관련 함수 종료

	
	
	
	
	function setCalendar() {
		//makeSimpleCalendar 바인딩
		coviCtrl.makeSimpleCalendar('sampleMakeSimpleCalendarDiv');

		//renderDateSelect 바인딩
		var timeInfos = {
			H : "1", // 시간 선택: '(입력한 숫자)시간'으로 범위 SelectBox의 옵션이 생성 (Ex. H : '2,3,5' 로 입력하였을 경우, 옵션이  2시간, 3시간, 5시간으로 생성)
			W : "1,2,3", // 주 선택
			M : "1", // 달 선택
			Y : "1" // 년도 선택
		};

		var initInfos = {
			useCalendarPicker : 'Y', // [필수] 날짜 선택 Input 사용여부 (Y/N)
			useTimePicker : 'Y', // [필수] 시간 선택 SelecBox 사용여부  (Y/N)
			useSeparation : 'Y', // [useTimePicker가 Y일 경우 필수] 시간 선택 시 시와 분 분리 여부  (Y/N)
			minuteInterval : 5, // [useTimePicker가 Y일 경우 필수] 분 시간 단위로 지정한 값이 60의 약수가 아닌 경우 그려지지 않음.
			changeTarget : 'end', // 범위 값 수정 시 변경대상이 될 값으로 start의 경우 end값 기준으로 start값이 변경되고, end일 경우 start값 기준으로 end값이 변경(start/end[default])
			use59 : 'Y' // TimePicker의 59분이 들어갈지 여부로 Y일 경우 minuteInteval 값에 상관없이 59분이 추가된다. (Y/N[default])
		};

		coviCtrl.renderDateSelect('sampleRenderDateSelectDiv', timeInfos, initInfos);

		//renderDateSelect2 바인딩
		var initInfos2 = {
			useCalendarPicker : 'Y', // [필수] 날짜 선택 Input 사용여부 (Y/N)
			useTimePicker : 'Y', // [필수] 시간 선택 SelecBox 사용여부  (Y/N)
			useSeparation : 'Y', // [useTimePicker가 Y일 경우 필수] 시간 선택 시 시와 분 분리 여부  (Y/N)
			minuteInterval : 10, // [useTimePicker가 Y일 경우 필수] 분 시간 단위로 지정한 값이 60의 약수가 아닌 경우 그려지지 않음.
			changeTarget : 'end', // 범위 값 수정 시 변경대상이 될 값으로 start의 경우 end값 기준으로 start값이 변경되고, end일 경우 start값 기준으로 end값이 변경(start/end[default])
			use59 : 'N' // TimePicker의 59분이 들어갈지 여부로 Y일 경우 minuteInteval 값에 상관없이 59분이 추가된다. (Y/N[default])
		};

		coviCtrl.renderDateSelect3('sampleRenderDateSelect2Div', initInfos2);
		
		//renderDateSelect3 바인딩
		var initInfos3 = {
				useCalendarPicker : 'Y',	//캘린더 paicker의 사용여부로, 날짜를 선택하는 달력의 사용여부를 묻는 옵션입니다.
				useTimePicker : 'N',	//time picker의 사용여부로, 00:00 부터 23:00 까지의 시간을 선택하는 select box의 사용여부를 묻는 옵션입니다.
				useBar : 'Y'	//time picker 사이의 bar의 사용여부를 묻는 옵션입니다.
		};
		var num = 1;

		coviCtrl.renderDateSelect3('sampleRenderDateSelect3Div', initInfos3,num);
	}

	// makeSimpleCalendar 관련 함수 시작
	function setMakeSimpleCalendar() {
		$("#sampleMakeSimpleCalendarDiv_Date").val("1998.11.28");
	}
	function getMakeSimpleCalendar() {
		//var returnData = $('#' + target + '_Date').val();;
		var returnData = coviCtrl
				.getSimpleCalendar('sampleMakeSimpleCalendarDiv');

		alert("선택된 날짜: " + returnData);
	}
	// makeSimpleCalendar 관련 함수 종료

	// renderDateSelect 관련 함수 시작
	function setRenderDateSelect() {
		$("#sampleRenderDateSelectDiv_StartDate").val("1998.11.28");
		$("#sampleRenderDateSelectDiv_EndDate").val("1998.11.28");

		coviCtrl.setSelected('sampleRenderDateSelectDiv [name=datePicker]',
				"select");
		coviCtrl
				.setSelected('sampleRenderDateSelectDiv [name=startHour]', "10");
		coviCtrl.setSelected('sampleRenderDateSelectDiv [name=startMinute]',
				"00");
		coviCtrl.setSelected('sampleRenderDateSelectDiv [name=endHour]', "11");
		coviCtrl
				.setSelected('sampleRenderDateSelectDiv [name=endMinute]', "00");
	}
	function getRenderDateSelect() {
		var returnData = coviCtrl
				.getDataByParentId("sampleRenderDateSelectDiv");

		alert("시간범위: " + returnData.selPicker + "\n" + "시작일시: "
				+ returnData.startDate + " " + returnData.startHour + ":"
				+ returnData.startMinute + "\n" + "종료일시: " + returnData.endDate
				+ " " + returnData.endHour + ":" + returnData.endMinute);
	}
	// renderDateSelect 관련 함수 종료

	// renderDateSelect2 관련 함수 시작
	function setRenderDateSelect2() {
		$("#sampleRenderDateSelect2Div_StartDate").val("1998.11.28");
		$("#sampleRenderDateSelect2Div_EndDate").val("1998.11.28");

		coviCtrl.setSelected('sampleRenderDateSelect2Div [name=startHour]',
				"10");
		coviCtrl.setSelected('sampleRenderDateSelect2Div [name=startMinute]',
				"00");
		coviCtrl.setSelected('sampleRenderDateSelect2Div [name=endHour]', "11");
		coviCtrl.setSelected('sampleRenderDateSelect2Div [name=endMinute]',
				"00");
	}
	function getRenderDateSelect2() {
		var returnData = coviCtrl
				.getDataByParentId("sampleRenderDateSelect2Div");

		alert("시작일시: " + returnData.startDate + " " + returnData.startHour
				+ ":" + returnData.startMinute + "\n" + "종료일시: "
				+ returnData.endDate + " " + returnData.endHour + ":"
				+ returnData.endMinute);
	}
	// renderDateSelect2 관련 함수 종료
	
	// renderDateSelect3 관련 함수 시작
	function setRenderDateSelect3() {
		$("#sampleRenderDateSelect3Div_StartDate").val("1998.11.28");
		$("#sampleRenderDateSelect3Div_EndDate").val("1998.11.28");

		coviCtrl.setSelected('sampleRenderDateSelect3Div [name=startHour]',
				"10");
		coviCtrl.setSelected('sampleRenderDateSelect3Div [name=startMinute]',
				"00");
		coviCtrl.setSelected('sampleRenderDateSelect3Div [name=endHour]', "11");
		coviCtrl.setSelected('sampleRenderDateSelect3Div [name=endMinute]',
				"00");
	}
	function getRenderDateSelect3() {
		var returnData = coviCtrl
				.getDataByParentId("sampleRenderDateSelect3Div");

		alert("시작일시: " + returnData.startDate + " " + returnData.startHour
				+ ":" + returnData.startMinute + "\n" + "종료일시: "
				+ returnData.endDate + " " + returnData.endHour + ":"
				+ returnData.endMinute);
	}
	// renderDateSelect3 관련 함수 종료

	function setAutoComplete() {
		//setCustomAjaxAutoTags 바인딩
		coviCtrl.setCustomAjaxAutoTags('sampleSetCustomAjaxAutoTagsDiv',
				'/covicore/control/getAllUserGroupAutoTagList.do', {
					labelKey : 'Name' // [필수] AJax를 통해 가져온 데이터 중 Label 역할을 할 속성 Key
					,
					valueKey : 'Code' // [필수] AJax를 통해 가져온 데이터 중 Value 역할을 할 속성 Key
					,
					multiselect : true // 1개 이상의 데이터 선택 가능 여부 (true/false[default])
					,
					useEnter : false // multiselect 값이 true 일 때 자동완성되지 않는 데이터 입력하고 사용자가 Enter를 치는 경우 태그로 등록할지 여부 (true/false[default])
					,
					minLength : 1 // 자동완성 데이터를 검색할 최소 글자수로 지정하지 않을 경우 1
					,
					useDuplication : false // 중복된 데이터 허용여부 (true/false[default])
					,
					callType : '' // 메일 시스템과 구분을 두기 위한 Type으로  메일이 아닐 경우 지정하지 않아도 됨(Mail/빈값 또는 지정하지 않음)
					,
					callBackFunction : 'callBackSetCustomAjaxAutoTags' // 자동완성 데이터 선택 시 호출될 함수명으로 선택된 데이터가 매개변수로 넘거가며 지정하지 않을 경우 별도 호출없음
				/*,select : function(event,ui) {					// 자동완성 데이터 선택 시 Tag가 생기는 기본 select함수와 다른 처리를 하고 싶은 경우 처리 함수 지정 
					ui.item.value = '';
						
					// TODO 태그 선택 시 실행될 내용 기술
				}*/
				});

		//setCustomAutoTags 바인딩
		var source = [ {
			id : 'apple',
			name : '사과'
		}, {
			id : 'tangerine',
			name : '귤'
		}, {
			id : 'persimmon',
			name : '감'
		}, {
			id : 'banana',
			name : '바나나'
		}, {
			id : 'orange',
			name : '오렌지'
		}, {
			id : 'grape',
			name : '포도'
		}, {
			id : 'watermelon',
			name : '수박'
		}, {
			id : 'mango',
			name : '망고'
		}, {
			id : 'Durian',
			name : '두리안'
		}, {
			id : 'rich',
			name : '리치'
		}, {
			id : 'Jackfruit',
			name : '잭푸르츠'
		}, {
			id : 'pineapple',
			name : '파인애플'
		} ];

		coviCtrl.setCustomAutoTags('sampleSetCustomAutoTagsDiv', source, {
			labelKey : 'name' // [필수] AJax를 통해 가져온 데이터 중 Label 역할을 할 속성 Key
			,
			valueKey : 'id' // [필수] AJax를 통해 가져온 데이터 중 Value 역할을 할 속성 Key
			,
			multiselect : true // 1개 이상의 데이터 선택 가능 여부 (true/false[default])
			,
			useEnter : false // multiselect 값이 true 일 때 자동완성되지 않는 데이터 입력하고 사용자가 Enter를 치는 경우 태그로 등록할지 여부 (true/false[default])
			,
			minLength : 1 // 자동완성 데이터를 검색할 최소 글자수로 지정하지 않을 경우 1
			,
			useDuplication : false // 중복된 데이터 허용여부 (true/false[default])
			,
			callBackFunction : 'callBackSetCustomAutoTags' // 자동완성 데이터 선택 시 호출될 함수명으로 선택된 데이터가 매개변수로 넘거가며 지정하지 않을 경우 별도 호출없음
		/*,select : function(event,ui) {					// 자동완성 데이터 선택 시 Tag가 생기는 기본 select함수와 다른 처리를 하고 싶은 경우 처리 함수 지정 
			ui.item.value = '';
				
			// TODO 태그 선택 시 실행될 내용 기술
		}*/
		});
	}

	// setCustomAjaxAutoTags 관련 함수 시작
	function getSetCustomAjaxAutoTags() {
		var alertStr = "[태그목록]";
		var autoTagArr = coviCtrl.getAutoTags("sampleSetCustomAjaxAutoTagsDiv");

		$(autoTagArr).each(
				function(idx, obj) {
					alertStr += "\n" + (idx + 1) + ". (label: " + obj.label
							+ ", value: " + obj.value + ")";
				});
		alertStr += "\n\n※ 상세한 조회 데이터는 console log 확인 바랍니다";

		coviCmn.traceLog("setCustomAjaxAutoTags 태그목록 조회", autoTagArr);
		alert(alertStr);
	}
	function setSetCustomAjaxAutoTags() {
		$("#sampleSetCustomAjaxAutoTagsDiv").siblings(
				".ui-autocomplete-multiselect-item").find("span.ui-icon-close")
				.click();

		//label과 value 이 외 속성은 Ajax에서 가져온 데이터에 따라 다름
		coviCtrl.setAutoTags("sampleSetCustomAjaxAutoTagsDiv", {
			"Code" : "RD",
			"Name" : "기술연구소",
			"Type" : "GR",
			"DeptName" : "",
			"label" : "기술연구소",
			"value" : "RD"
		});
	}
	function callBackSetCustomAjaxAutoTags(item) {
		coviCmn.traceLog("setCustomAjaxAutoTags CallBack", item);
	}
	// setCustomAjaxAutoTags 관련 함수 종료

	// setCustomAutoTags 관련 함수 시작
	function getSetCustomAutoTags() {
		var alertStr = "[태그목록]";
		var autoTagArr = coviCtrl.getAutoTags("sampleSetCustomAutoTagsDiv");

		$(autoTagArr).each(
				function(idx, obj) {
					alertStr += "\n" + (idx + 1) + ". (label: " + obj.label
							+ ", value: " + obj.value + ")";
				});
		alertStr += "\n\n※ 상세한 조회 데이터는 console log 확인 바랍니다";

		coviCmn.traceLog("setCustomAutoTags 태그목록 조회", autoTagArr);
		alert(alertStr);
	}
	function setSetCustomAutoTags() {
		$("#sampleSetCustomAutoTagsDiv").siblings(
				".ui-autocomplete-multiselect-item").find("span.ui-icon-close")
				.click();

		//label과 value 이 외 속성은 에서 가져온 데이터에 따라 다름
		coviCtrl.setAutoTags("sampleSetCustomAutoTagsDiv", {
			id : 'Durian',
			name : '두리안',
			value : 'Durian',
			label : '두리안'
		});
	}
	function callBackSetCustomAutoTags(item) {
		coviCmn.traceLog("setCustomAutoTags CallBack", item);
	}
	// setCustomAutoTags 관련 함수 종료

	function setPicker() {
		// renderColorPicker 바인딩
		var colorInfos = [ {
			"default" : "#4a86e8"
		}, {
			"ac725e" : "#ac725e"
		}, {
			"d06a65" : "#d06a65"
		}, {
			"f83a22" : "#f83a22"
		}, {
			"fb573c" : "#fb573c"
		}, {
			"ff7537" : "#ff7537"
		}, {
			"ffae45" : "#ffae45"
		}, {
			"f4e06c" : "#f4e06c"
		}, {
			"fad165" : "#fad165"
		}, {
			"43d692" : "#43d692"
		}, {
			"9fc6e7" : "#9fc6e7"
		}, {
			"4a86e8" : "#4a86e8"
		}, {
			"9a9cff" : "#9a9cff"
		}, {
			"b99bff" : "#b99bff"
		}, {
			"a479e2" : "#a479e2"
		}, {
			"cd75e6" : "#cd75e6"
		}, {
			"f691b1" : "#f691b1"
		}, {
			"cda5ad" : "#cda5ad"
		}, {
			"c9bdbf" : "#c9bdbf"
		} ]; //모듈별로 사용가능한 컬러는 일반적으로 기초코드에 등록 (ex, 일정관리 Common.getBaseCode("ScheduleColor"); ) 

		coviCtrl.renderColorPicker("sampleRenderColorPickerDiv", colorInfos);
	}

	// renderColorPicker 관련 함수 시작
	function getRenderColorPicker() {
		var selectedColor = coviCtrl.getSelectColor();

		alert("선택된 색깔 key: "
				+ coviCmn.isNull(selectedColor.split(":")[0], "없습니다")
				+ "\n선택된 색깔 value: " + selectedColor.split(":")[1]);
	}
	function setRenderColorPicker() {
		coviCtrl.setSelectColor("f691b1");
	}
	// renderColorPicker 관련 함수 종료

	function setOrgChart() {
		// render 바인딩
		var orgOpt = {
			targetID : 'sampleCoviOrgRenderDiv', // [필수] 조직도가 그려질 div 태그의 ID
			drawOpt : 'LM___', // 조직도의 다섯 부분 중 그려질 부븐을 지정하는 값으로 5자리로 구성되며 그리지 않을 부분은 '_'로 입력 (기본값은 'LMARB')
			allCompany : "Y", // 전체 계열사 표시 여부로 N일 경우 현재 세션의 계열사만 표시 (Y[default]/N)
			treeKind : "Dept" // 조직도에 표시될 트리 종류 지정
		};

		coviOrg.render(orgOpt);
	}

	// 조직도 팝업 관련 함수 시작
	var initData;
	function goOrgChartPopup() {
		var type = $("#sampleOrgChartPopupType").val();
		var treeKind = $("#sampleOrgChartPopupTreeKind").val();
		var allCompany = $("#sampleOrgChartPopupAllCompany").val();
		var bizcardKind = $("#sampleOrgChartPopupBizcardKind").val();
		if (type == "" || treeKind == "" || allCompany == "") {
			alert("조직도 호출에 필요한 옵션을 지정해주세요");
			return false;
		}
		initData = $("#sampleOrgChartPopupTextarea").val();
		var width = (type == "A0" ? "1230px" : "1060px");
		var height = (type == "A0" ? "675px" : "585px");
		var orgURL = String
				.format(
						"/covicore/control/goOrgChart.do?type={0}&treeKind={1}&allCompany={2}&bizcardKind={3}&callBackFunc=callBackOrgChartPopup&setParamData=initData",
						type, treeKind, allCompany,bizcardKind);

		Common.open("", "orgcharPopup",
				"<spring:message code='Cache.lbl_DeptOrgMap'/>", orgURL, width,
				height, "iframe", true, null, null, true);
	}
	function callBackOrgChartPopup(result) {
		$("#sampleOrgChartPopupTextarea").val(result);
	}
	// 조직도 팝업 관련 함수 종료

	var g_containerID = 'tbContentElement';
	var g_editorKind = Common.getBaseConfig('EditorType');
	function setEditor() {
		$("#sampleLoadEditorType").text(g_editorKind);

		// loadEditor 바인딩
		coviEditor.loadEditor('sampleLoadEditorDiv', {
			editorType : g_editorKind, // [필수] 표시할 Editor 타입의 이름 또는 번호 지정
			containerID : g_containerID, // [필수] Editor 프레임의 name 값을 임의로 지정
			frameHeight : '400', // 에디터 높이로 지정하지 않은 경우 600px로 바인딩
			focusObjID : '', // 에디터 바인딩 완료 후 포커스를 받을 객체 ID로 없을 시 빈값 또는 미지정
			useResize : 'Y', // 에디터 높이 변경 버튼 표시 여부 (Y/N[default])
			bizSection : 'Devhelper', // 모듈 별 아이디 (ex. 게시판-Board, 일정관리-Schedule, 자원예약-Resource)
			onLoad : function() { // 에디터 바인딩 완료 후 실행될 함수명(string) 또는 함수(function) 
				coviEditor.setBody(g_editorKind, g_containerID, "<p>초기값</p>");
			}
		});
	}

	// loadEditor 관련 함수 시작
	function setLoadEditor() {
		var strHtml = '<p style="font-family: &quot;맑은 고딕&quot;; font-size: 11pt; line-height: 17.6px; margin-top: 0px; margin-bottom: 0px;"><strong>setBody를 사용하여 Editor 내용을 변경합니다.&nbsp;</strong></p>';
		coviEditor.setBody(g_editorKind, g_containerID, strHtml);

		$("#sampleLoadEditorPreviewDiv").hide();
	}
	function getLoadEditor() {

		var images = coviEditor.getImages(g_editorKind, g_containerID);
		var bodyHtml = coviEditor.getBody(g_editorKind, g_containerID, true);
		var bodyText = coviEditor.getBodyText(g_editorKind, g_containerID);

		$("#sampleLoadEditorPreview").html(bodyHtml);
		$("#sampleLoadEditorPreviewDiv").show();

		alert("Inline Images: " + (images == "" ? "없음" : images)
				+ "\nBodyText: " + bodyText
				+ "\nBodyHtml: 화면의 [Editor 내용] 확인바랍니다");

	}
	function moveToBackLoadEditor() {
		var images = coviEditor.getImages(g_editorKind, g_containerID);
		var bodyHtml = coviEditor.getBody(g_editorKind, g_containerID);

		if (images == "") {
			alert("인라인 이미지가 없습니다.");
			return;
		}

		$
				.ajax({
					type : "POST",
					url : "/covicore/devhelper/editor/uploadToBackInlineImage.do",
					data : {
						"inlineImages" : images,
						"bodyHtml" : bodyHtml
					},
					success : function(data) {
						if (data.status = 'SUCCESS') {
							$("#sampleLoadEditorPreview").html(data.bodyHtml);
							$("#sampleLoadEditorPreviewDiv").show();
						}
					},
					error : function(response, status, error) {
						CFN_ErrorAjax(
								"/covicore/devhelper/editor/uploadToBackInlineImage.do",
								response, status, error);
					}
				});

	}
	// loadEditor 관련 함수 종료
	var sampleCalendar;
	function setCoviCalendar() {
		$("#sampleCalendarViewDiv").off("load").on("load", function(e) {
			console.log('콜백처리', e.currentTarget);
		});
		$("#sampleCalendarViewDiv").html("");
		sampleCalendar = CoviCalendar('sampleCalendarViewDiv');
	}

	function coviCalSetMark() {
		var day = $("#markday").val();
		sampleCalendar.setMark(day);
	}

	function coviCalClearMark() {
		sampleCalendar.clearMark();
	}
	
	//게시판 관련 함수 시작
	var messageGrid = new coviGrid();//게시글 Grid 

	function setBoard(){
		messageGrid.setGridHeader([	
			{key:'MessageID', label:'번호', width:'10', align:'center'},     //번호
			{key:'Subject', label:'제목', width:'30', align:'center'},     //제목
			{key:'CreatorName', label:'등록자', width:'30', align:'center'},     //등록자
			{key:'RegistDate', label:'등록일', width:'30', align:'center',sort:"desc"}    //등록일
		]);

		messageGrid.setGridConfig({
			targetID: "messageGrid",
			height: "auto", //default: 400
			page: {
				pageSize: 5 //default: 10 
			},
			paging: true //default: true 
		});

		messageGrid.bindGrid({
			ajaxUrl:"/covicore/devhelper/boardGridSample.do",
			ajaxPars: {
				pageSize: messageGrid.page.pageSize
			}
		});
	}
	
	$("#sampleInputModeType").change(function(){
		$("#SampleInputBox_M").val("");
		$("#SampleInputBox_M").attr("mode",$("#sampleInputModeType").val());
		$("#SampleInputBox_M").removeAttr("allow_minus max_length max_round");
		
		switch($("#SampleInputBox_M").attr("mode")){
		case 'money' :
			$("#SampleInputBox_M").attr({
				allow_minus: true,
				max_length: 10,
				max_round:3 
			});
			$("#SampleInputBox_M").val("-abc123,.45-67891234")
			break;
		case 'moneyint' :
			$("#SampleInputBox_M").attr({
				max_length: 7
			});
			$("#SampleInputBox_M").val("123.45678908")
			break;
		case 'number' :
			$("#SampleInputBox_M").attr({
				allow_minus: true,
				max_length: 10,
				max_round:3 
			});
			$("#SampleInputBox_M").val("123.123456789")
			break;
		case 'numberint' :
			$("#SampleInputBox_M").attr({
				max_length: 7
			});
			$("#SampleInputBox_M").val("123.4234234324")
			break;
		case 'date' :
			$("#SampleInputBox_M").val("2023-09-01")
			break;
		case 'date-ymd' :
			$("#SampleInputBox_M").val("2023년12월03일")
			break;
		case 'time' :
			$("#SampleInputBox_M").val("12:00")
			break;
		case 'date-slash' :
			$("#SampleInputBox_M").val("2023/09/21")
			break;
		case 'datetime-ymd' :
			$("#SampleInputBox_M").val("2023년09월21일20시00시00")
			break;
		case 'custom' :
			$("#SampleInputBox_M").val("!@#$%^&*()")
			break;
		case 'bizno' :
			$("#SampleInputBox_M").val("123-45-67890")
			break;
		case 'phone' :
			$("#SampleInputBox_M").val("010-1111-1111")
			break;
		default:
			return true;
		}
		coviInput.init();
	});
	
	var sampleInputKindInfo = "";
	$("#sampleInputKindType").change(function(){
		$("#SampleInputBox_K").val("");
		$("#SmpleInbutBox_K_info").val("");
		$("#SampleInputBox_K").attr("kind",$("#sampleInputKindType").val());
		$("#SampleInputBox_K").removeAttr("num_min num_max allow_minus off_value on_value min max unit snap style align valign separator selectType defaultSelectType defaultDate minDate maxDate onBeforeShowDay class");
		$("#inputBasic_AX_SampleInputBox_K").remove();
		
		switch($("#SampleInputBox_K").attr("kind")){
		case 'number' :
			$("#SampleInputBox_K").attr({
				num_min : "1" ,
				num_max : "999",
				allow_minus : true
			});
			$("#SampleInputBox_K").val("1")
			coviInput.setNumber();
			sampleInputKindInfo = "input text 엘리먼트에 숫자 컨트롤을 바인딩 합니다.";
			break;
		case 'money' :
			$("#SampleInputBox_K").val("10000");
			coviInput.setMoney();
			sampleInputKindInfo = "input text 엘리먼트에 통화단위가 입력 되도록 합니다.";
			break;
		case 'switch' :
			$("#SampleInputBox_K").attr({
				off_value : "AM" ,
				on_value : "PM",
				readonly_Fg : undefined
			});
			coviInput.setSwitch();
			sampleInputKindInfo = "input text 엘리먼트에 스위치 컨트롤을 적용합니다.";
			break;
		case 'slider' :
			$("#SampleInputBox_K").attr({
				slider_min: 0,    
			    slider_max: 100,  
			    snap: 0.01, 
			    unit: "%", 
			    value: 1000,
			    class:"AXInput W200"
			});
			coviInput.setSlider(); 
			sampleInputKindInfo = "input text 엘리먼트에 slider 컨트롤을 바인딩 합니다.";
			break;
		case 'twinslider' :
			$("#SampleInputBox_K").attr({
				twslider_min : 0,   
			    twslider_max : 100,  
			    separator: "~", 
			    snap: 0.1,
			    unit: "%", 
			    class:"AXInput W200"
			});
			coviInput.setTwinSlider();
			sampleInputKindInfo = "input text 엘리먼트에 번위 선택이 가능한 slider 컨트롤을 바인딩 합니다.";
			break;
		case 'dictionary' :
			$("#SampleInputBox_K").val("테스트 입니다.");
			coviInput.setDictionary();
			sampleInputKindInfo = "input text 엘리먼트에 번위 선택이 가능한 slider 컨트롤을 바인딩 합니다.(다국어 이벤트 세팅)";
			$("#SampleInputBox_K").remove();
			break;
		case 'date' :
			$("#SampleInputBox_K").attr({
				align            :"right", 
			    valign           :"top",  
			    separator        : "-",    
			    selectType       : "d",   
			    defaultSelectType: "d",   
			    defaultDate      : "",   
			    minDate          : "",    
			    maxDate          : ""   
			    //onBeforeShowDay  : {}      // {Function} 날짜를 보여주기 전에 호출하는 함수. date를 파라미터로 받으며 다음과 같은 형식의 Object를 반환해야 한다. { isEnable: true|false, title:'성탄절', className: 'holyday', style: 'color:red' }
			});
			coviInput.setDate();
			sampleInputKindInfo = "input text 엘리먼트에 바인딩된 날짜 컨트롤을 제거합니다.";
		default:
			return true;
		}
		
		$("#SmpleInbutBox_K_info").text("설명 : " + sampleInputKindInfo);
	});

</script>