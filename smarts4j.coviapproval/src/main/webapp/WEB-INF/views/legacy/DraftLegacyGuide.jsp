<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<!doctype html>
<%
	// Session 없이 접근하는 페이지임.
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	pageContext.setAttribute("isUseMail", PropertiesUtil.getExtensionProperties().getProperty("isUse.mail"));
	pageContext.setAttribute("isUseAccount", PropertiesUtil.getExtensionProperties().getProperty("isUse.account"));
	pageContext.setAttribute("isUseProjectmng", PropertiesUtil.getExtensionProperties().getProperty("isUse.projectmng"));
	pageContext.setAttribute("isUseWebhard", PropertiesUtil.getExtensionProperties().getProperty("isUse.webhard"));
	pageContext.setAttribute("isUseBizMnt", PropertiesUtil.getExtensionProperties().getProperty("isUse.bizMnt"));
	pageContext.setAttribute("isUseHrManage", PropertiesUtil.getExtensionProperties().getProperty("isUse.hrmanage"));
	pageContext.setAttribute("themeType", "blue"); // SessionHelper.getSession("UR_ThemeType")
	pageContext.setAttribute("themeCode", "default"); // SessionHelper.getSession("UR_ThemeCode")
	pageContext.setAttribute("LanguageCode", "ko"); // SessionHelper.getSession("LanguageCode")		
%>

<html lang="ko">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=1280">
	<title>기안연동 가이드</title>
	
	<!-- 공통영역은 user_defailt.jsp , UserInclude.jsp 기준-->
	<link rel="stylesheet" type="text/css" href="/covicore/resources/css/font-awesome-4.7.0/css/font-awesome.min.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXJ.min.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXGrid.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXTree.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery.mCustomScrollbar.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>" />	
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />  
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/survey/resources/css/survey.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/schedule/resources/css/schedule.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/resource/resources/css/resource.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/board/resources/css/board.css<%=resourceVersion%>" />	
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/doc/resources/css/doc.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/bizcard/resources/css/bizcard.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/community/resources/css/community.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/task/resources/css/task.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/myInfo/resources/css/myInfo.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/extension/resources/css/extension.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/VacationManager/resources/css/VacationManager.css<%=resourceVersion%>" />	
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/palette-color-picker.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/slick.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/AttendanceManagement/resources/css/AttendanceManagement.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/AttendanceManagement/resources/css/AttendanceMgt.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/IntegratedTaskManagement/resources/css/IntegratedTaskManagement.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/collaboration/resources/css/collaboration.css<%=resourceVersion%>">
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/webhard/resources/css/webhard.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/public/resources/css/public.css<%=resourceVersion%>" />
	<!-- 간편관리자 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/simpleAdmin/resources/css/simpleAdmin.css">
	<link rel="stylesheet" id="themeCSS" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/blue.css<%=resourceVersion%>" />
	<link rel="stylesheet" id="languageCSS" type="text/css" href="<%=cssPath%>/covicore/resources/css/language/ko.css<%=resourceVersion%>" />
	<!--[if lt IE 9]>
	  <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js<%=resourceVersion%>"></script>
	<![endif]-->
	<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.mousewheel.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.mCustomScrollbar.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/typed.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/bootstrap.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXGrid.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/idle-timer.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/axisj/AXTree.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.editor.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.acl.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.control.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/autosize.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.notify.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/validation.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.policy.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/Dictionary.js<%=resourceVersion%>"></script>
	
	<script type="text/javascript" src="/covicore/resources/script/palette-color-picker.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/slick.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.slimscroll.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/html2canvas.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/clipboard.min.js<%=resourceVersion%>"></script>
	
	<!-- covision util 함수  -->
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.util.js<%=resourceVersion%>"></script>
	
	<!--  파라메터 유호성 체크 -->
	<script type="text/javascript" src="/covicore/resources/script/security/aes.js"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/x64-core.js"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/sha256.js"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js"></script>
	
	<style>
		.sadminContent .helppopup { text-align:left; }
		.sadminContent .helppopup p { line-height:normal; }
		.sadminContent .helppopup p:not(:last-child) { margin-bottom:5px; } 
		.sadminContent .vtop td,.sadminContent .vtop th { vertical-align:top; }
		.sadminContent table tr:hover td,.sadminContent table tr:hover th { background: #e1edf5; }
		.sadminContent .txt-red { color:red; }
		.sadminContent table td,.sadminContent table th { height:40px; padding:10px !important; line-height:normal; }
		.sadminContent table.taCenter td,.sadminContent table.taCenter th { text-align:center !important; }
		.sadminContent .link-pointer { cursor:pointer; }
		.sadminContent h3 { margin-top:30px; font-size:20px; }
		.sadminContent table.sadmin_table input[type="text"] { width:100% !important;}
		.sadminContent table.sadmin_table textarea { width:100%;}
	</style>
	
	<script type="text/javascript">
		//ready시 호출
		$(document).ready(function() {
			fn_bindData(); // 기본 데이터 바인드
			fn_bindEvent(); // 이벤트 바인드
			setTestList(); // 테스트 데이터 가져오기 - 가이드 3 내부 중간테이블 , 가이드 4 연동시스템 테이블
		});
		
		// 이벤트 바인드
		function fn_bindEvent(){
			// 도움말
			$('.collabo_help02 .help_ico').on('click', function(){
				if($(this).hasClass('active')){
					$(this).removeClass('active');
				}else {
					$(this).addClass('active')
				}
			});
			
			// 탭메뉴
			$('.tabMenu>li').on('click', function(){
				var idx = $(this).index();
				$('.tabMenu>li').removeClass('active');
				$('.tabContent').removeClass('active');
				$(this).addClass('active');
				$('.tabContent').eq(idx).addClass('active');
				if(idx == 1) changeParameter("AUTO", $('.tabContent').eq(idx).find("[name='tbl_test']")); // 자동기안 파라미터 셋팅 
			});
			
			// 설명 보기/숨기기
			$('[name="tit_desc"]').on('click', function(){
				var oTarget = $(this).parent();
				if($(oTarget).find('[name="cont_desc"]').is(":visible")){
					$(oTarget).find('[name="tit_desc"]').text("설명 ▼");
					$(oTarget).find('[name="cont_desc"]').hide();
				}else{
					$(oTarget).find('[name="tit_desc"]').text("설명 ▲");
					$(oTarget).find('[name="cont_desc"]').show();
				}
			});
			
			// 연동 종류에 따른 파라미터 변경
			$("[name='dataType']").on('change', function(){
				changeParameter($(this).val(),$(this).closest("table"));
			});
			$("[name='dataType']").trigger("change");
			
		}
		
		// 기본 데이터 바인드
		function fn_bindData(){
			
			// 연동타입별 공통 설명 추가
			var descHtml = `<tr>
					<th>
						기안 방식
						<div class="collabo_help02">
							<a href="javascript:void(0);" class="help_ico"></a>
							<div class="helppopup" style="width:400px;">
								 <p><b>*양식오픈</b> - 데이터를 셋팅한 결재문서 작성창 오픈</p>
								 <p><b>*자동기안</b> - 데이터로 결재문서 자동기안(결재선 필요)</p>
							</div>
						</div>
					</th>
					<td name="draft_type"></td>
					<th>
						데이터 입력방식
						<div class="collabo_help02">
							<a href="javascript:void(0);" class="help_ico"></a>
							<div class="helppopup" style="width:400px;">
								 <p><b>*입력 데이터(기본)</b> - api를 통해 실시간으로 입력받은 데이터로 연동</p>
								 <p><b>*내부 중간테이블(GWDB)</b> - 그룹웨어 내에 있는 중간테이블 데이터로 연동(사전에 연동시스템에서 그룹웨어 중간테이블에 데이터 입력 필요)</p>
								 <p><b>*연동시스템 테이블(EXTDB)</b> - 연동시스템의 테이블 데이터로 연동('연동시스템 테이블 설정' 메뉴에서 대상 테이블 설정 필요)</p>
							</div>
						</div>
					</th>
					<td name="input_type"></td>
				</tr>`;
				
			$("[name='tbl_desc']").each(function(i,item){
				$(item).find("tbody").prepend(descHtml);
				var dtype = "";
				var itype = "";
				switch(i){
					case 0: dtype = "양식오픈"; itype = "입력 데이터(기본)"; break; // 가이드 1 양식오픈 (양식오픈,입력데이터)
					case 1: dtype = "자동기안"; itype = "입력 데이터(기본)"; break; // 가이드 2 자동기안 (자동기안,입력데이터)
					case 2: dtype = "양식오픈"; itype = "내부 중간테이블(GWDB)"; break; // 가이드 3 내부 중간테이블 (양식오픈,내부 중간테이블)
					case 3: dtype = "양식오픈"; itype = "연동시스템 테이블(EXTDB)"; break; // 가이드 4 연동시스템 테이블 (양식오픈,연동시스템 테이블)
				}
				$(item).find("[name='draft_type']").text(dtype);
				$(item).find("[name='input_type']").text(itype);
			});
			
			var descapvLegacyData = '{ \n'+
			'	"division": [\n'+
			'		{\n'+
			'			"index": "1",\n'+
			'			"type": "send",\n'+
			'			"step": [\n'+
			'				{\n'+
			'					"index": "1",\n'+
			'					"type": "Approve",\n'+
			'					"userCode": "user1",\n'+
			'					"deptCode": "deptCode"\n'+
			'				},\n'+
			'				{\n'+
			'					"index": "2",\n'+
			'					"type": "P_P_Consult",\n'+
			'					"userCode": "user2",\n'+
			'					"deptCode": "deptCode"\n'+
			'				},\n'+
			'				{\n'+
			'					"index": "2",\n'+
			'					"type": "P_P_Consult",\n'+
			'					"userCode": "user3",\n'+
			'					"deptCode": "deptCode"\n'+
			'				},\n'+
			'				{\n'+
			'					"index": "3",\n'+
			'					"type": "Approve",\n'+
			'					"userCode": "user4",\n'+
			'					"deptCode": "deptCode"\n'+
			'				}\n'+
			'			]\n'+
			'		},\n'+
			'		{\n'+
			'			"index": "2",\n'+
			'			"type": "receive",\n'+
			'			"step": [\n'+
			'				{\n'+
			'					"index": "1",\n'+
			'					"type": "Rec_Dept",\n'+
			'					"deptCode": "dept2"\n'+
			'				}\n'+
			'			]\n'+
			'		}\n'+
			'	],\n'+
			'	"ccinfo": {\n'+
			'		"type": "Before",\n'+
			'		"kind": "Send",\n'+
			'		"userCode": "user5"\n'+
			'	}\n'+
			'}'
			$("#apvLegacyData").val(descapvLegacyData);
		}
		
		// 테스트 데이터 가져오기 - 가이드 3 내부 중간테이블 , 가이드 4 연동시스템 테이블
		function setTestList() {
			$.ajax({
				type:"POST",
				data:{
				},
				async : true,
				url:"/approval/legacy/getDraftLegacyGuideList.do",
				success:function (data) {			
					if(data.status == "SUCCESS"){
						try{
							$.each(data.list3, function(idx,item){
								var shtml = "<tr>";
								shtml += "<td style='text-align:center;'>"
								shtml += '<input type="checkbox" name="chkTest" onclick="fn_Uncheck(this);" SystemCode="' + item.SystemCode + '" LEGACYKEY="' + item.LEGACYKEY + '" DataSourceType="GWDB">'
								shtml += "</td>";
								shtml += "<td>" + item.LegacyID + "</td>";
								shtml += "<td>" + item.SystemCode + "</td>";
								shtml += "<td>" + item.LEGACYKEY + "</td>";
								shtml += "<td>" + item.EMPNO + "</td>";
								shtml += "<td>" + item.DEPT_ID + "</td>";
								shtml += "<td>" + item.FORM_PREFIX + "</td>";
								shtml += "<td>" + item.SUBJECT + "</td>";
								shtml += "<td>" + item.DATA_TYPE + "</td>";
								$('#guide_3_body').append(shtml);
							});
							
							$.each(data.list4, function(idx,item){
								var shtml = "<tr>";
								shtml += "<td style='text-align:center;'>"
								shtml += '<input type="checkbox" name="chkTest" onclick="fn_Uncheck(this);" SystemCode="SAMPLE" InstanceID="' + item.InstanceID + '" DataSourceType="EXTDB">'
								shtml += "</td>";
								shtml += "<td>SAMPLE</td>";
								shtml += "<td>" + item.InstanceID + "</td>";
								shtml += "<td>" + item.BT_PERSON_EMPNO + "</td>";
								shtml += "<td>" + item.BT_DEPT_CODE + "</td>";
								shtml += "<td>" + item.SUBJECT + "</td>";
								shtml += "<td>JSON</td>";
								$('#guide_4_body').append(shtml);
							});
							
						}catch(e){
							alert(e.message);
						}
					}else {
	                    Common.Error(data.message);
	                }
				},
				error:function(response, status, error){
					CFN_ErrorAjax("getDraftLegacyGuideList.do", response, status, error);
				}
			});
		}
		
		function fn_Uncheck(pObj){
			$("[name='chkTest']").not(pObj).prop("checked",false);
		}
		
		// 연동 종류에 따른 파라미터 변경
		function changeParameter(pType, pTarget){
			//changeParameter($(this).val(),$(this).closest("table"));
			
			var sApvlist = `{"steps":{"division":{"divisiontype":"send","name":"발신","oucode":"test0001","ouname":"test0001;test0001;test0001;test0001;;;;;;;","taskinfo":{"status":"inactive","result":"inactive","kind":"send","datereceived":"2022-11-29 14:45:29"},"step":[{"unittype":"person","routetype":"approve","name":"기안자","ou":{"code":"test0001","name":"test0001;test0001;test0001;test0001;;;;;;;","person":{"code":"superadmin","name":"슈퍼관리자;;;;;;;;;","position":"150;부사장;Vice president;副社長;副经理;;;;;;;","title":"TTEST_0;TEST;TEST;TEST;TEST;;;;;;;","level":"L180;testTitle11;testTitle11;testTitle11;testTitle11;;;;;;;","oucode":"test0001","ouname":"test0001;test0001;test0001;test0001;;;;;;;","sipaddress":"superadmin@covision.co.kr","taskinfo":{"status":"inactive","result":"inactive","kind":"charge","datereceived":"2022-11-29 14:45:29"}}}},{"unittype":"person","ou":{"code":"test0001","person":{"code":"superadmin","taskinfo":{"result":"inactive","kind":"normal","status":"inactive"},"level":"L180;testTitle11;testTitle11;testTitle11;testTitle11;;;;;;;","name":"슈퍼관리자;;;;;;;;;","oucode":"test0001","position":"150;부사장;Vice president;副社長;副经理;;;;;;;","title":"TTEST_0;TEST;TEST;TEST;TEST;;;;;;;","ouname":"test0001;test0001;test0001;test0001;;;;;;;"},"name":"test0001;test0001;test0001;test0001;;;;;;;"},"name":"일반결재","routetype":"approve"}]}}}`;
			var sBodyContext = ""; 
			var sJson = `"BT_PERSON": "홍길동", "BT_PERSON_CODE": "", "SYSTEMTYPE": "", "INSTANCEID": "", "SUBJECT": "", "BT_DEPT": "IT팀", "BT_DEPT_CODE": "", "BT_AREA": "부산", "BT_PERPOSE": "업무협의", "BT_S_DATE": "2022-11-21", "BT_E_DATE": "2022-11-30", "JWF_DRAFT_LEGACY_TARGET_SAMPLEMULTI": [ { "R_BT_NAME": "홍길동", "R_BT_CODE": "", "R_BT_DEPT_NAME": "", "R_BT_DEPT_CODE": "", "MULTIID": "", "R_BT_TRANS": "50000", "R_BT_ROOM": "80000", "R_BT_WORK": "40000", "R_BT_ETC": "10000" }, { "R_BT_NAME": "김자바", "R_BT_CODE": "", "R_BT_DEPT_NAME": "", "R_BT_DEPT_CODE": "", "MULTIID": "", "R_BT_TRANS": "51000", "R_BT_ROOM": "82000", "R_BT_WORK": "40000", "R_BT_ETC": "11000" } ] `;
			var sHtml = `<p style=\\"margin:10px;font-size:18px;font-weight:bold;\\">입력받은 html 영역</p><p style=\\"font-size:13px;\\"> * 양식 html에 있는 모든 내용은 무시되며, 입력받은 html만 표시됩니다.</p><table class=\\"tableStyle linePlus mt10 table_3\\"><colgroup><col width=\\"5%\\"><col width=\\"23%\\"><col width=\\"24%\\"><col width=\\"24%\\"><col width=\\"24%\\"></colgroup><tr><th>No</th><th>데이터1</th><th>데이터2</th><th>데이터3</th><th>데이터4</th></tr><tr><td style=\\"text-align:center;\\">1</td><td style=\\"text-align:center;\\">\`~1!2@3#4$5%6^7&8*9(0)-_=+\\\\|[{]};:'\\",<.>/?</td><td style=\\"text-align:center;\\">테스트 데이터2</td><td style=\\"text-align:center;\\">테스트 데이터3</td><td style=\\"text-align:center;\\">테스트 데이터4</td></tr><tr><td style=\\"text-align:center;\\">2</td><td style=\\"text-align:center;\\">테스트 데이터5</td><td style=\\"text-align:center;\\">테스트 데이터6</td><td style=\\"text-align:center;\\">테스트 데이터7</td><td style=\\"text-align:center;\\">테스트 데이터8</td></tr></table>`;
			var sFormPrefix = "";
			
			switch(pType){
				case "HTML": // 가이드 1 양식오픈 (데이터타입 HTML)
					sFormPrefix = "WF_FORM_LEGACY_TEST";
					sBodyContext = `{`
						+ `\n\n\t"HTMLBody": "` + sHtml + `"`
						+ `\n\n\t,"MobileBody": "` + sHtml + `"`
						+ `\n\n}`;
				break;
				case "JSON": // 가이드 1 양식오픈 (데이터타입 JSON)
					sFormPrefix = "WF_FORM_LEGACY_TEST_JSON";
					sBodyContext = `{`
						+ `\n\n\t"JSONHtml": "` + sHtml + `"`
						+ `\n\n\t,` + sJson
						+ `\n}`;
				break;
				case "AUTO": // 가이드 2 자동기안
					sFormPrefix = "WF_FORM_LEGACY_TEST";
					sBodyContext = `{`
						+ `\n\n\t"HTMLBody": "` + sHtml + `"`
						+ `\n\n\t,"MobileBody": "` + sHtml + `"`
						+ `\n\n}`;
					$(pTarget).find("[name='apvline']").val(sApvlist);
				break;
			}
			$(pTarget).find("[name='bodyContext']").val(sBodyContext);
			$(pTarget).find("[name='legacyFormID']").val(sFormPrefix);
		}
		
		// 테스트 - 가이드 1 양식오픈 (양식오픈,입력데이터)
		function goTest1() {
			var target = $("#guide_1");
			
			var url = document.location.protocol + "//" + document.location.host+ "/approval/legacy/goFormLink.do";
			var apvLegacyData = $("#apvLegacyData").val() != "" ? Base64.utf8_to_b64(JSON.stringify(JSON.parse($("#apvLegacyData").val()))) : "";
			
			var form = document.createElement("form");
			form.method = "post"; form.target = "form"; form.action = url; form.style.display = "none";
	
			$(form).append($("<input>").attr("type","hidden").attr("name","mode").val($(target).find("[name='mode']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","key").val($(target).find("[name='key']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","subject").val($(target).find("[name='subject']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","empno").val($(target).find("[name='empno']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","logonId").val($(target).find("[name='logonId']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","deptId").val($(target).find("[name='deptId']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","legacyFormID").val($(target).find("[name='legacyFormID']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","dataType").val($(target).find("[name='dataType']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","language").val($(target).find("[name='language']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","isTempSaveBtn").val($(target).find("[name='isTempSaveBtn']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","bodyContext").val($(target).find("[name='bodyContext']").val()));
			$(form).append($("<input>").attr("type","hidden").attr("name","apvLegacyData").val(apvLegacyData));
			
			document.body.appendChild(form);
	
			window.open("","form","toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1,width=750,height=800");
			form.submit();
			form.remove();
		}
		
		
		// 테스트 - 가이드 2 자동기안 (자동기안,입력데이터)
		function goTest2() {
			var target = $("#guide_2");
			
			var formData = new FormData();
			formData.append("key", $(target).find("[name='key']").val());
			formData.append("subject", $(target).find("[name='subject']").val());
			formData.append("empno", $(target).find("[name='empno']").val());
			formData.append("logonId", $(target).find("[name='logonId']").val());
			formData.append("deptId", $(target).find("[name='deptId']").val());
			formData.append("legacyFormID", $(target).find("[name='legacyFormID']").val());
			formData.append("language", $(target).find("[name='language']").val());
			formData.append("apvline", $(target).find("[name='apvline']").val());
			formData.append("bodyContext", $(target).find("[name='bodyContext']").val());
			
			$.ajax({
				url:"/approval/legacy/draftForLegacy.do",
				type:"post",
				data:formData,
		    	dataType : 'json',
		        processData : false,
		        contentType : false,
				success:function (data) {
					if(data.status=='SUCCESS'){
						alert("결재상신에 성공하였습니다.");
					}
					else {
						alert(data.message);
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/legacy/draftForLegacy.do", response, status, error);
				}
			});
		}
		
		
		// 테스트 - 가이드 3 내부 중간테이블 (양식오픈,내부 중간테이블)
		function goTest3() {
			
			var oChecked = $("#guide_3").find("[name='chkTest']:checked");
			if($(oChecked).length != 1){
				alert("리스트에서 테스트할 데이터를 1개 선택 해주세요.");
				return false;
			}
			
			var sDataSourceType = $(oChecked).attr("DataSourceType"); // GWDB
			var sSystemCode = $(oChecked).attr("SystemCode");
			var sLEGACYKEY = $(oChecked).attr("LEGACYKEY");
			
			var url = document.location.protocol + "//" + document.location.host+ "/approval/legacy/goFormLinkForDB.do";
			var form = document.createElement("form");
			form.method = "post"; form.target = "form"; form.action = url; form.style.display = "none";
	
			$(form).append($("<input>").attr("type","hidden").attr("name","dataSoureType").val(sDataSourceType));
			$(form).append($("<input>").attr("type","hidden").attr("name","systemCode").val(sSystemCode));
			$(form).append($("<input>").attr("type","hidden").attr("name","key").val(sLEGACYKEY));
			
			document.body.appendChild(form);
	
			window.open("","form","toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1,width=750,height=800");
			form.submit();
			form.remove();
		}
		
		
		// 테스트 - 가이드 4 연동시스템 테이블 (양식오픈,연동시스템 테이블)
		function goTest4() {
			
			var oChecked = $("#guide_4").find("[name='chkTest']:checked");
			if($(oChecked).length != 1){
				alert("리스트에서 테스트할 데이터를 1개 선택 해주세요.");
				return false;
			}
			
			var sDataSourceType = $(oChecked).attr("DataSourceType"); // EXTDB
			var sSystemCode = $(oChecked).attr("SystemCode");
			var sInstanceID = $(oChecked).attr("InstanceID");
			
			var url = document.location.protocol + "//" + document.location.host+ "/approval/legacy/goFormLinkForDB.do";
			var form = document.createElement("form");
			form.method = "post"; form.target = "form"; form.action = url; form.style.display = "none";
	
			$(form).append($("<input>").attr("type","hidden").attr("name","dataSoureType").val(sDataSourceType));
			$(form).append($("<input>").attr("type","hidden").attr("name","systemCode").val(sSystemCode));
			$(form).append($("<input>").attr("type","hidden").attr("name","key").val(sInstanceID));
			
			document.body.appendChild(form);
	
			window.open("","form","toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1,width=750,height=800");
			form.submit();
			form.remove();
		}
		
	</script>
</head>

<body>
	<div class="cRConTop titType AtnTop">
		<h2 class="title">기안연동 가이드</h2>
		<div class="searchBox02">
		</div>
	</div>
	<div class="cRContBottom mScrollVH">
		<div class="sadminContent">
			<div style="margin:5px;" class="txt-red"><b>* 세션이 변경될 수 있으므로, 로그아웃 후 세션이 없는 상태에서 테스트 하세요.</b></div>
			
			<!-- 탭영역 -->
			<ul class="tabMenu clearFloat" style="margin-bottom:0px;margin-top:5px;">
				<li class="active"><a href="javascript:void(0);">양식오픈</a></li> <!-- 가이드 1 양식오픈 (양식오픈,입력데이터) -->
				<li class=""><a href="javascript:void(0);">자동기안</a></li> <!-- 가이드 2 자동기안 (자동기안,입력데이터) -->
	  			<li class=""><a href="javascript:void(0);">내부 중간테이블</a></li> <!-- 가이드 3 내부 중간테이블 (양식오픈,내부 중간테이블) -->
	  			<li class=""><a href="javascript:void(0);">연동시스템(외부) 테이블</a></li> <!-- 가이드 4 연동시스템 테이블 (양식오픈,연동시스템 테이블) -->
			</ul>
			
			<!-- 가이드 1 양식오픈 (양식오픈,입력데이터) -->
			<div id="guide_1" class="tabContent active">
				<!-- 설명 -->
				<h3 name="tit_desc" class="link-pointer">설명 ▲</h3>
				<div name="cont_desc">
					<table name="tbl_desc" class="sadmin_table vtop" style="margin-top:10px;">
						<colgroup>
							<col width="10%">
							<col width="40%">
							<col width="10%">
							<col width="40%">
						</colgroup>
						<tbody>
							<!-- 연동타입별 공통 설명 추가될 부분 -->
							<tr>
								<th>설명</th>
								<td colspan="3">
									- 입력받은 내용을 바인딩하여 양식 작성창을 띄우는 방식 (HTML,JSON)<br>
									- HTML은 양식본문 자체를 html 데이터로 입력받아 그대로 보여주는 방식<br>
									&nbsp;&nbsp;양식파일의 html내용은 무시되고 입력받은 값으로 바인딩<br>
									&nbsp;&nbsp;데이터 자체는 JSON으로 입력받고 특정 키에 html데이터를 받음<br>
									&nbsp;&nbsp;양식 내용에 상관 없이 입력 받은 값으로 bodycontext가 유지됨(Legacy Key값 및 공통 bodycontext 값은 자동으로 추가)<br>
									- JSON은 bodycontext 데이터를 입력받아 바인딩 하는 방식<br>
									- 입력된 사용자로 인증(OneTimeSession)처리 후 입력된 데이터 기준으로 양식 오픈
								</td>
							</tr>
							<tr>
								<th>관련 소스</th>
								<td colspan="3">
									- /smarts4j.coviapproval/src/main/webapp/WEB-INF/views/legacy/DraftLegacyGuide.jsp<br>
									&nbsp;&nbsp;테스트 페이지 <br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/legacy/web/ForLegacyCon.java (goFormLink.do)<br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/legacy/service/impl/ForLegacySvcImpl.java<br>
									&nbsp;&nbsp;연동 API, 데이터셋팅 및 로그인 처리<br>
									- /smarts4j.coviapproval/src/main/webapp/WEB-INF/views/forms/FormForLegacy.jsp<br>
									&nbsp;&nbsp;중간페이지(양식페이지로 redirect만 함)<br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/form/web/FormCon.java (approval_Form.do)<br>
									&nbsp;&nbsp;양식페이지
								</td>
							</tr>
							<tr>
								<th>관련 DB</th>
								<td colspan="3">
									- covi_approval4j.jwf_formslegacy : 연동가능 양식목록(양식관리에서 "외부연동" 체크하면 자동으로 들어감)
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- 테스트 -->
				<h3 name="tit_test">테스트</h3>
				<div name="cont_test">
					<a onclick="goTest1();" class="btnTypeDefault btnTypeBg">연동 테스트</a>
					<table name="tbl_test" class="sadmin_table sa_design vtop" style="margin-top:10px;">
						<colgroup>
							<col width="25%">
							<col width="10%">
							<col width="65%">
						</colgroup>
						<tbody>
							<tr>
								<th>
									문서 상태<br>
									<p class="explain02">기안시에는 DRAFT 고정</p>
								</th>
								<th>mode</th>
								<td><input type="text" id="mode" name="mode" value="DRAFT" /></td>
							</tr>
							<tr>
								<th>
									Legacy Key<br>
									<p class="explain02">연동시스템의 키값(bodycontext LegacySystemKey 에 저장됨)</p>
								</th>
								<th>key</th>
								<td><input type="text" id="key" name="key" value="123456" /></td>
							</tr>
							<tr>
								<th>
									문서제목
								</th>
								<th>subject</th>
								<td><input type="text" id="subject" name="subject" value="기안연동 테스트"></td>
							</tr>
							<tr>
								<th>
									기안자 사번<br>
									<p class="explain02">사번/로그인아이디 둘중 하나만 넘겨도 가능</p>
								</th>
								<th>empno</th>
								<td><input type="text" id="empno" name="empno" value="000001" /></td>
							</tr>
							<tr>
								<th>
									기안자 로그인아이디<br>
									<p class="explain02">사번/로그인아이디 둘중 하나만 넘겨도 가능</p>
								</th>
								<th >logonId</th>
								<td><input type="text" id="logonId" name="logonId" value="superadmin" /></td>
							</tr>
							<tr>
								<th >
									기안자 부서코드<br>
									<p class="explain02">생략가능, 생략하면 본직으로 처리되므로 겸직부서 처리가 필요하면 필수값</p>
								</th>
								<th >deptId</th>
								<td><input type="text" id="deptId" name="deptId" value="" /></td>
							</tr>
							<tr>
								<th >
									양식 KEY값<br>
									<p class="explain02">jwf_formslegacy 테이블에 등록된 LegacyForm값 (formprefix)</p>
								</th>
								<th >legacyFormID</th>
								<td><input type="text" id="legacyFormID" name="legacyFormID" value="WF_FORM_LEGACY_TEST" /></td>
							</tr>
							<tr>
								<th >
									데이터타입<br>
									<p class="explain02">
										<b>*HTML</b> : 양식파일의 자체 내용은 무시되며, 입력받은 html을 양식본문에 그대로 표시, 결재진행중에도 api에서 입력받은 bodycontext가 그대로 유지됨<br>
										<b>*JSON</b> : 입력받은 bodycontext 데이터를 양식에 바인딩(html과 bodycontext 모두를 사용해야된다면, JSON방식으로 하고 양식js에서 별도로 html 처리 필요)<br>
										<b>*ALL</b> : HTML과 같음
									</p>
								</th>
								<th >dataType</th>
								<td>
									<select id="dataType" name="dataType" style="width:100px;">
										<option value="HTML" selected>HTML</option>
										<option value="JSON">JSON</option>
										<!--  <option value="ALL" selected>ALL</option> --> <!-- HTML과 방식 같음 -->
									</select>
								</td>
							</tr>
							<tr>
								<th >
									다국어 코드<br>
									<p class="explain02">생략가능, 생략하면 사용자정보 테이블의 기본 언어코드로 처리</p>
								</th>
								<th >language</th>
								<td><input type="text" id="language" name="language" value="ko" /></td>
							</tr>
							<tr>
								<th >
									임시저장 버튼 표시 여부<br>
									<p class="explain02">생략가능, 버튼을 보이지 않을경우에만 N으로 설정</p>
								</th>
								<th >isTempSaveBtn</th>
								<td><input type="text" id="isTempSaveBtn" name="isTempSaveBtn" value="" /></td>
							</tr>
							<tr>
								<th >
									본문<br>
									<p class="explain02">
										데이터 구조는 json이며 내부 키값에 따라 구분됨 <br>
										*데이터 타입이 HTML일때는 HTMLBody,MobileBody 키에 html 데이터를 입력<br>
									</p>
								</th>
								<th >bodycontext</th>
								<td>
									<textarea id="bodyContext" name="bodyContext"style="height: 200px;"></textarea>
								</td>
							</tr>
							<tr>
								<th>
									연동 결재선 데이터<br>
									<p class="explain02">
										기간계로부터 사번/부서코드를 전달받아, 코비젼에서 사용하는 결재선 생성함. 데이터가 없을경우 양식에서 결재선 선택<br><br>
										* 예시)기간계에서 넘겨받을 결재선<br>
										* 발신부서 type : Approve, P_P_Consult, P_S_Consult, D_P_Consult, D_S_Consult, P_P_Assist, P_S_Assist, D_P_Assist, D_S_Assist<br>
										* 수신부서 type : Rec_Dept<br>
										* 접수, 재기안시 결재선 division[0]의 type을 redraft로 다시 받을 것!! division[1] 불필요. 접수는 결재선없을시 세션사용자로 처리<br>
										※ 발신부서 type.split("_")<br>
											- 첫번째값 : P(개인) or D(부서)<br>
											- 두번째값 : S(순차) or P(병렬)<br>
											- 세번째값 : Consult(합의) or Assist(협조)
									</p>
								</th>
								<th >apvLegacyData</th>
								<td>
									<textarea id="apvLegacyData" name="apvLegacyData"style="height: 150px;"></textarea>
									※ 샘플데이터 설명 : 기안(user1) -> 개인병렬합의(user2, user3) -> 결재(user4) -> 부서수신(dept2). 사전참조(user5)
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
			</div> <!-- guide_1 -->
			
			
			<!-- 가이드 2 자동기안 (자동기안,입력데이터) -->
			<div id="guide_2" class="tabContent">
				<!-- 설명 -->
				<h3 name="tit_desc" class="link-pointer">설명 ▲</h3>
				<div name="cont_desc">
					<table name="tbl_desc" class="sadmin_table vtop" style="margin-top:10px;">
						<colgroup>
							<col width="10%">
							<col width="40%">
							<col width="10%">
							<col width="40%">
						</colgroup>
						<tbody>
							<!-- 연동타입별 공통 설명 추가될 부분 -->
							<tr>
								<th  >설명</th>
								<td colspan="3">
									- 입력받은 내용을 바인딩하여 자동으로 기안하는 방식<br>
									- 결재선도 필수로 필요하며, bodycontext에 입력할 데이터 및 공통 데이터도 모두 필요하다.<br>
									&nbsp;&nbsp;필수 : 커스텀된 헤더/commonfield 의 mField<br>
									&nbsp;&nbsp;InitiatorDisplay,InitiatorOUDisplay 는 자동으로 추가됨
								</td>
							</tr>
							<tr>
								<th>관련 소스</th>
								<td colspan="3">
									- /smarts4j.coviapproval/src/main/webapp/WEB-INF/views/legacy/DraftLegacyGuide.jsp<br>
									&nbsp;&nbsp;테스트 페이지 <br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/legacy/web/ForLegacyCon.java (draftForLegacy.do)<br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/legacy/service/impl/ForLegacySvcImpl.java<br>
									&nbsp;&nbsp;연동 API, 연동 처리 없이 기안자 정보만 넣어서 기안 처리<br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/form/service/impl/ApvProcessSvcImpl.java<br>
									&nbsp;&nbsp;양식기안처리
								</td>
							</tr>
							<tr>
								<th>관련 DB</th>
								<td colspan="3">
									- covi_approval4j.jwf_formslegacy : 연동가능 양식목록(양식관리에서 "외부연동" 체크하면 자동으로 들어감)
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- 테스트 -->
				<h3 name="tit_test">테스트</h3>
				<div name="cont_test">
					<a onclick="goTest2();" class="btnTypeDefault btnTypeBg">연동 테스트</a>
					<table name="tbl_test" class="sadmin_table sa_design vtop" style="margin-top:10px;">
						<colgroup>
							<col width="20%">
							<col width="10%">
							<col width="70%">
						</colgroup>
						<tbody>
							<tr>
								<th >
									Legacy Key<br>
									<p class="explain02">연동시스템의 키값(bodycontext LegacySystemKey 에 저장됨)</p>
								</th>
								<th >key</th>
								<td><input type="text" id="key" name="key" value="123456" /></td>
							</tr>
							<tr>
								<th >
									문서제목
								</th>
								<th >subject</th>
								<td><input type="text" id="subject" name="subject" value="기안연동 테스트"></td>
							</tr>
							<tr>
								<th >
									기안자 사번<br>
									<p class="explain02">사번/로그인아이디 둘중 하나만 넘겨도 가능</p>
								</th>
								<th >empno</th>
								<td><input type="text" id="empno" name="empno" value="000001" /></td>
							</tr>
							<tr>
								<th >
									기안자 로그인아이디<br>
									<p class="explain02">사번/로그인아이디 둘중 하나만 넘겨도 가능</p>
								</th>
								<th >logonId</th>
								<td><input type="text" id="logonId" name="logonId" value="superadmin" /></td>
							</tr>
							<tr>
								<th >
									기안자 부서코드<br>
									<p class="explain02">생략가능, 생략하면 본직으로 처리되므로 겸직부서 처리가 필요하면 필수값</p>
								</th>
								<th >deptId</th>
								<td><input type="text" id="deptId" name="deptId" value="" /></td>
							</tr>
							<tr>
								<th >
									양식 KEY값<br>
									<p class="explain02">jwf_formslegacy 테이블에 등록된 LegacyForm값 (formprefix)</p>
								</th>
								<th >legacyFormID</th>
								<td><input type="text" id="legacyFormID" name="legacyFormID" value="WF_FORM_LEGACY_TEST" /></td>
							</tr>
							<tr>
								<th >
									다국어 코드<br>
									<p class="explain02">생략가능, 생략하면 사용자정보 테이블의 기본 언어코드로 처리</p>
								</th>
								<th >language</th>
								<td><input type="text" id="language" name="language" value="ko" /></td>
							</tr>
							<tr>
								<th >
									결재선<br>
									<p class="explain02">
										실제 전자결재에서 사용되는 결재선 JSON
									</p>
								</th>
								<th >apvline</th>
								<td>
									<textarea id="apvline" name="apvline"style="height: 200px;"></textarea>
								</td>
							</tr>
							<tr>
								<th >
									본문<br>
									<p class="explain02">
										데이터 구조는 json이며 내부 키값에 따라 구분됨 <br>
										*데이터 타입이 HTML일때는 HTMLBody,MobileBody 키에 html 데이터를 입력<br>
									</p>
								</th>
								<th >bodycontext</th>
								<td>
									<textarea id="bodyContext" name="bodyContext"style="height: 200px;"></textarea>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
			</div> <!-- guide_2 -->
			
			
			<!-- 가이드 3 내부 중간테이블 (양식오픈,내부 중간테이블) -->
			<div id="guide_3" class="tabContent">
				<!-- 설명 -->
				<h3 name="tit_desc" class="link-pointer">설명 ▲</h3>
				<div name="cont_desc">
					<table name="tbl_desc" class="sadmin_table vtop" style="margin-top:10px;">
						<colgroup>
							<col width="10%">
							<col width="40%">
							<col width="10%">
							<col width="40%">
						</colgroup>
						<tbody>
							<!-- 연동타입별 공통 설명 추가될 부분 -->
							<tr>
								<th  >설명</th>
								<td colspan="3">
									- 그룹웨어 내부 중간테이블 데이터를 이용하여 양식 오픈<br>
									- 사전에 연동 시스템에서 그룹웨어 테이블에 데이터 insert 필요(covi_approval4j.jwf_draft_legacy_list)<br>
									- 데이터 타입(HTML,JSON) 등 방식은 "양식오픈" 탭과 동일
								</td>
							</tr>
							<tr>
								<th>관련 소스</th>
								<td colspan="3">
									- /smarts4j.coviapproval/src/main/webapp/WEB-INF/views/legacy/DraftLegacyGuide.jsp<br>
									&nbsp;&nbsp;테스트 페이지 <br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/legacy/web/ForLegacyCon.java (goFormLinkForDB.do)<br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/legacy/service/impl/ForLegacySvcImpl.java<br>
									&nbsp;&nbsp;연동 API, 테이블 데이터 조회 후 셋팅 및 로그인 처리<br>
									- /smarts4j.coviapproval/src/main/webapp/WEB-INF/views/forms/FormForLegacy.jsp<br>
									&nbsp;&nbsp;중간페이지(양식페이지로 redirect만 함)<br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/form/web/FormCon.java (approval_Form.do)<br>
									&nbsp;&nbsp;양식페이지
								</td>
							</tr>
							<tr>
								<th>관련 DB</th>
								<td colspan="3">
									- covi_approval4j.jwf_formslegacy : 연동가능 양식목록(양식관리에서 "외부연동" 체크하면 자동으로 들어감)<br>
									- covi_approval4j.jwf_draft_legacy_list : 그룹웨어 중간테이블<br>
									&nbsp;&nbsp;내부키값(LegacyId)이 있지만 연동 시스템(외부)에서 호출한다는 가정으로 해당 값(SystemCode,LegacyKey)으로 테스트
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- 테스트 -->
				<h3 name="tit_test">테스트</h3>
				<div name="cont_test">
					<a onclick="goTest3();" class="btnTypeDefault btnTypeBg">연동 테스트</a>
					<table name="tbl_test" class="sadmin_table sa_design vtop" style="margin-top:10px;">
						<colgroup>
							<col width="5%">
							<col width="10%">
							<col width="10%">
							<col width="10%">
							<col width="10%">
							<col width="10%">
							<col width="10%">
							<col width="25%">
							<col width="10%">
						</colgroup>
						<thead>
							<tr>
								<th style="text-align:center;'">선택</th>
								<th>LegacyId<br>내부테이블키</th>
								<th>SystemCode<br>연동시스템명</th>
								<th>LegacyKey<br>연동시스템키</th>
								<th>EmpNo<br>기안자사번</th>
								<th>
									Dept_ID<br>기안자부서코드
									<div class="collabo_help02">
										<a href="javascript:void(0);" class="help_ico"></a>
										<div class="helppopup" style="width:300px;">
											 <p>생략가능, 생략하면 본직으로 기안, 겸직정보가 필요하면 필수</p>
										</div>
									</div>
								</th>
								<th>FormPrefix<br>양식키</th>
								<th>Subject<br>문서제목</th>
								<th>Data_Type<br>연동데이터타입</th>
							</tr>
						</thead>
						<tbody id="guide_3_body">
						</tbody>
					</table>
				</div>
				
			</div> <!-- guide_3 -->
			
	
			<!-- 가이드 4 연동시스템 테이블 (양식오픈,연동시스템 테이블) -->
			<div id="guide_4" class="tabContent">
				<!-- 설명 -->
				<h3 name="tit_desc" class="link-pointer">설명 ▲</h3>
				<div name="cont_desc">
					<table name="tbl_desc" class="sadmin_table vtop" style="margin-top:10px;">
						<colgroup>
							<col width="10%">
							<col width="40%">
							<col width="10%">
							<col width="40%">
						</colgroup>
						<tbody>
							<!-- 연동타입별 공통 설명 추가될 부분 -->
							<tr>
								<th  >설명</th>
								<td colspan="3">
									- 연동시스템(외부) 테이블 데이터를 이용하여 양식 오픈<br>
									- 사전에 "시스템관리 > 외부DB연계설정 > Datasource 관리" 메뉴에서 연동 시스템 DB 등록 후 
									&nbsp;&nbsp;연동시스템 테이블 설정" 메뉴에서 테이블 및 컬럼 정보 설정 필요(jwf_draft_legacy_target)<br>
									- 여기서는 테스트이므로 그룹웨어 DB정보 등록 후 그룹웨어 내부테이블로 테스트 진행<br>
									- 테이블 전체 데이터를 이용하므로 데이터 타입은 JSON 으로 고정<br>
									- 연동시스템 테이블 데이터를 bodycontext로 변환시 모두 컬렴명의 대문자로 적용되며, 멀티로우는 테이블명으로 적용됩니다.<br>
									- 데이터 조회 방식<br>
									&nbsp;&nbsp;데이터 : select * from [데이터테이블명] where [데이터테이블키컬럼] = {전달받은키값}<br>
									&nbsp;&nbsp;멀티로우 : select * from [멀티로우테이블명] where [멀티로우테이블키컬럼] = {전달받은키값}
								</td>
							</tr>
							<tr>
								<th>관련 소스</th>
								<td colspan="3">
									- /smarts4j.coviapproval/src/main/webapp/WEB-INF/views/legacy/DraftLegacyGuide.jsp<br>
									&nbsp;&nbsp;테스트 페이지 <br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/legacy/web/ForLegacyCon.java (goFormLinkForDB.do)<br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/legacy/service/impl/ForLegacySvcImpl.java<br>
									&nbsp;&nbsp;연동 API, 테이블 데이터 조회 후 셋팅 및 로그인 처리<br>
									- /smarts4j.coviapproval/src/main/webapp/WEB-INF/views/forms/FormForLegacy.jsp<br>
									&nbsp;&nbsp;중간페이지(양식페이지로 redirect만 함)<br>
									- /smarts4j.coviapproval/src/main/java/egovframework/covision/coviflow/form/web/FormCon.java (approval_Form.do)<br>
									&nbsp;&nbsp;양식페이지
								</td>
							</tr>
							<tr>
								<th>관련 DB</th>
								<td colspan="3">
									- covi_approval4j.jwf_formslegacy : 연동가능 양식목록(양식관리에서 "외부연동" 체크하면 자동으로 들어감)<br>
									- covi_approval4j.jwf_draft_legacy_target : 연동시스템(외부) 종류 및 테이블/컬럼 정보<br>
									- covi_approval4j.jwf_draft_legacy_target_sampledata : 테스트용 샘플(외부 테이블의 데이터 테이블 역할)<br>
									- covi_approval4j.jwf_draft_legacy_target_samplemulti : 테스트용 샘플(외부 테이블의 멀티로우 테이블 역할)<br>
									&nbsp;&nbsp;연동 시스템(외부)에서 호출한다는 가정으로 해당 jwf_draft_legacy_target.SystemCode , jwf_draft_legacy_target_samplemulti.InstanceID 으로 테스트
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- 테스트 -->
				<h3 name="tit_test">테스트</h3>
				<div name="cont_test">
					<a onclick="goTest4();" class="btnTypeDefault btnTypeBg">연동 테스트</a>
					<table name="tbl_test" class="sadmin_table sa_design vtop" style="margin-top:10px;">
						<colgroup>
							<col width="5%">
							<col width="13%">
							<col width="13%">
							<col width="13%">
							<col width="13%">
							<col width="30%">
							<col width="13%">
						</colgroup>
						<thead>
							<tr>
								<th style="text-align:center;'">선택</th>
								<th>
									SystemCode<br>연동시스템명
									<div class="collabo_help02">
										<a href="javascript:void(0);" class="help_ico"></a>
										<div class="helppopup" style="width:300px;">
											 <p>샘플 연동시스템이 SAMPLE 이므로 SAMPLE로 고정</p>
										</div>
									</div>
								</th>
								<th>InstanceID<br>연동시스템키</th>
								<th>BT_PERSON_EMPNO<br>기안자사번</th>
								<th>
									BT_DEPT_CODE<br>기안자부서코드
									<div class="collabo_help02">
										<a href="javascript:void(0);" class="help_ico"></a>
										<div class="helppopup" style="width:300px;">
											 <p>생략가능, 생략하면 본직으로 기안, 겸직정보가 필요하면 필수</p>
										</div>
									</div>
								</th>
								<th>Subject<br>문서제목</th>
								<th>
									Data_Type<br>연동데이터타입
									<div class="collabo_help02">
										<a href="javascript:void(0);" class="help_ico"></a>
										<div class="helppopup" style="width:300px;">
											 <p>테이블 전체 데이터를 이용하므로 데이터 타입은 JSON 으로 고정</p>
										</div>
									</div>
								</th>
							</tr>
						</thead>
						<tbody id="guide_4_body">
						</tbody>
					</table>
				</div>
				
			</div> <!-- guide_4 -->
			
	
		</div>
	</div> <!-- cRContBottom mScrollVH -->
	
	
	
</body>
</html>	
