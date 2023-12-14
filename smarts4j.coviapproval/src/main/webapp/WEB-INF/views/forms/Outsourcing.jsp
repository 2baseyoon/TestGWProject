<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<!-- 외주 용역 품의서 인쇄 양식   -->

<!-- 양식개선 새 컴포넌트 모음 -->
<link type="text/css" rel="stylesheet" href="<%=cssPath%>/approval/resources/css/xeasy/xeasy.0.9.css<%=resourceVersion%>" />
<script type="text/javascript" src="resources/script/xeasy/xeasy-number.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/xeasy/xeasy-numeral.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/xeasy/xeasy-timepicker.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/xeasy/xeasy.multirow.0.9.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/xeasy/xeasy4j.0.9.2.js<%=resourceVersion%>"></script>

<style>
td{
	padding: 2px 0px;
	line-height:normal;
}
body {
	margin: 0;
	padding: 0;
}

* {
	box-sizing: border-box;
	-moz-box-sizing: border-box;
}

.page {
	width: 21cm;
	min-height: 29.7cm;
	/* padding: 2cm; */
	margin: 0 auto;
	/* background:#eee; */
}

.subpage {
	border: 2px black solid;
	/* background:#fff; */   
	height: 257mm;
	width: 100%;
}

@page {
	size: A4;
	margin-left: 4.19mm;
	margin-right: 3.32mm;
	margin-top: 5.35mm;
	margin-bottom: 1mm
}

@media print {
	html, body {
		width: 210mm;
		height: 297mm;
	}
	.page {
		/*padding:1cm;*/
		border: initial;
		width: initial;
		min-height: initial;
		/* box-shadow: initial; */
		/* background: initial; */
		page-break-after: always;
	}
	
}

</style>
<body>
<div id='printShow'  class="page">
    <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;" class="subpage"> 
       	<colgroup>
       		<col style="width: 14%"> 
       		<col style="width: 3%" >
			<col style="width: 6%" > 
			<col style="width: 7%" > 
			<col style="width: 7%" > 
			<col style="width: 11%" >
			<col style="width: 10%" >
			<col style="width: 7%" >
			<col style="width: 7%" >
			<col style="width: 5%" >
			<col style="width: 6%" > 
			<col style="width: 4%" >
			<col style="width: 6%" > 
			<col style="width: 7%" >
		</colgroup>
		<tbody>
			<tr>  
				<td colspan="3"  style="border-top: 2px solid black;  border-left: 2px solid black;  border-bottom: 2px solid black;  text-align: center; ">
					<img alt="logo" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.png" style="width: 154px; "id="footerLogo"/>
				</td>  
				<td colspan="11" style="padding: 10px 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none; font-size: 23pt; font-weight: 700; text-align: center; border-bottom: 2px solid black;  border-top: 2px solid black; border-right: 2px solid black; ">
					&nbsp;외주용역 (프로젝트) 수행 계약서&nbsp;
				</td> 
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-right: 2px solid black; border-color: black; height: 29px;">
					계약일자
				</td>  
				<td colspan="13" style="padding: 0px; padding-left: 3px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black; border-left: none;">
					<span id="OrderDate"></span><!-- 2019년 1월 17일 목요일  -->
				</td> 
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px;  font-family: '맑은 고딕', monospace; vertical-align: middle; border-bottom: none; border-right: 2px solid black; color: black; font-size: 12pt; font-weight: 700; text-align: center; border-right: 2px solid black;  border-left: 2px solid black; height: 29px; border-top: none;">
					계약번호
				</td>  
				<td colspan="13" style="padding: 0px; padding-left: 3px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-bottom: none;  color: black; font-size: 12pt; font-weight: 700; border-top: 1px solid black; border-right: 2px solid black; border-left: none;">
					<p id="OrderNum"></p>
				</td> 
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  font-size: 12pt; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black; border-right: 2px solid black;  background: rgb(217, 217, 217); height: 29px;">
					계약자 구분
				</td>  
				<td colspan="2" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(217, 217, 217); border-left: none;">
					법인
				</td>  
				<td colspan="2" height="29" style="height: 29px; border-top: 1px solid black; " align="left" valign="top">
					<span id="chkContractCompany" style="padding-top: 2px;position: absolute; margin-left: 20.25pt;">□</span>  
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(217, 217, 217);">
					일반사업자
				</td>  
				<td colspan="2" height="29" style="height: 29px; border-top: 1px solid black; " align="left" valign="top">
					<span id="chkContractPerson2" style="padding-top: 2px;position: absolute; margin-left: 20.25pt;">□</span>  
				</td>  
				<td colspan="2" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(217, 217, 217);">
					개인
				</td>  
				<td colspan="2" height="29" style="height: 29px; border-top: 1px solid black; " align="left" valign="top">
					<span id="chkContractPerson"  style="padding-top: 2px;position: absolute; margin-left: 20.25pt;">□</span>  
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black;">
					<p><br/></p>
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-right: 2px solid black; border-bottom: 1px solid black;">
					<p><br/></p>
				</td> 
			</tr> 
			<tr>  
				<td rowspan="3" height="87" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; font-size: 12pt; font-weight: 700; text-align: center; border-width: 2px; border-style: solid; border-color: black black black; background: rgb(255, 242, 204);  height: 88px;">
					갑
				</td>  
				<td colspan="4" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 2px solid black;  border-bottom: 1px solid black; background: rgb(255, 242, 204); border-right: 1px solid black; border-left: none;">
					회사명
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 2px solid black;  border-bottom: 1px solid black; border-right: 1px solid black; border-left: none;">
					㈜코비젼
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 2px solid black; border-bottom: 1px solid black; background: rgb(255, 242, 204); border-right: 1px solid black; border-left: none;">
					연락처
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 2px solid black;  border-bottom: 1px solid black; border-right: 2px solid black; border-left: none;">
					02-6965-3195
				</td> 
			</tr> 
			<tr>  
				<td colspan="4" height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(255, 242, 204); border-right: 1px solid black; height: 29px; border-left: none;">
					대표이사
				</td>  
				<td colspan="2" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: none;">
					위장복
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; border-bottom: 1px solid black; border-top: none;">
					(인)
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-width: 1px; border-style: solid; border-color: black black black black; background: rgb(255, 242, 204);">
					사업자등록번호
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black; border-left: none;">
					109-81-73212
				</td> 
			</tr> 
			<tr>  
				<td colspan="4" height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 2px solid black; background: rgb(255, 242, 204); border-right: 1px solid black; height: 29px; border-left: none;">
					주소
				</td>  
				<td colspan="9" style="padding: 0px; padding-left:3px; font-family: '맑은 고딕', monospace; vertical-align: middle;   color: black; font-size: 12pt; border-top: 1px solid black; border-right: 2px solid black;  border-bottom: 2px solid black;">
					서울특별시 강서구 마곡중앙8로 7길 11,  디앤씨캠퍼스
				</td>  
			</tr> 
			<tr>  
				<td rowspan="3" height="87" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-width: 2px; border-style: solid; color: black; font-size: 12pt; font-weight: 700; text-align: center; background: rgb(255, 242, 204); height: 88px;">
					을
				</td>  
				<td colspan="4" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(255, 242, 204); border-right: 1px solid black; border-left: none;">
					회사명
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; border-left: none;">
					<p id="companyName"></p>
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(255, 242, 204); border-right: 1px solid black; border-left: none;">
					연락처
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					<p id="phoneNumber"></p>
				</td> 
			</tr> 
			<tr>  
				<td colspan="4" height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(255, 242, 204); border-right: 1px solid black; height: 29px; border-left: none;">
					대표이사<br/>/ 성명(일반사업자/개인)
				</td>  
				<td colspan="2" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: none;">
					<p id="ceoName"></p>
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; border-bottom: 1px solid black; border-top: none;">
					(인)
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-width: 1px; border-style: solid; border-color: black black black black; background: rgb(255, 242, 204);">
					사업자등록번호<br/>/ 주민등록번호
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					<p id="IDNumber"></p>
				</td> 
			</tr> 
			<tr>  
				<td colspan="4" height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 2px solid black; background: rgb(255, 242, 204); border-right: 1px solid black; height: 29px; border-left: none;">
					주소
				</td>  
				<td colspan="9" style="padding: 0px; padding-left:3px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: left; border-top: 1px solid black; border-bottom: 2px solid black; border-right: 2px solid black; border-left: none;">
					<p id="Address"></p>
				</td> 
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px; padding-left:3px; font-family: '맑은 고딕', monospace; vertical-align: middle; text-align: center;  border-top: none;  color: black; font-size: 12pt; font-weight: 700; border-right: 2px solid black; border-bottom: 1px solid black; border-left: 2px solid black; background: rgb(217, 217, 217); height: 29px;">
					프로젝트명
				</td>  
				<td colspan="13" style="padding: 0px; padding-left:3px;  font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none;  color: black; font-size: 12pt; text-align: left; border-bottom: 1px solid black; background: white; border-right: 2px solid black; border-left: none;">
					<p id="contractName"></p>
				</td> 
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-width: 1px 2px;; border-style: solid; border-color: black; background: rgb(217, 217, 217); height: 29px;">
					계약기간
				</td>  
				<td colspan="13" style="padding: 0px; padding-left:3px; font-size: 12pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: 2px solid black; color: black; text-align: left; border-top: 1px solid black; border-bottom: 1px solid black; border-left: none;">
					<p id="OrderPriod"></p>
				</td>  
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-width: 1px 2px; border-style: solid; border-color: black; background: rgb(217, 217, 217); height: 29px;">
					총 계약 금액
				</td>  
				<td colspan="2" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: none;">
					\
				</td>  
				<td colspan="2" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black;">
					<p id="total"></p><!-- 총 계약 금액 -->
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; text-align: center; border-bottom: 1px solid black; border-top: none;">
					일금
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black;">
					<p id="total1"></p> <!-- 총 계약 금액 (한글)  -->
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; border-top: 1px solid black; border-bottom: 1px solid black;">
					원정
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; border-bottom: 1px solid black; border-top: none;">
					<p><br/></p>
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; font-size: 12pt; border-right: 2px solid black; border-bottom: 1px solid black; border-top: none;">
					<p><br/></p>
				</td> 
			</tr> 
			<tr>  
				<td colspan="14" height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; text-align: center; border-width: 1px 2px; border-style: solid; border-color: black black black black; height: 29px;">
					㈜ 코비젼 (이하 "갑" 이라고 칭함) 과&nbsp;<p name="signName" style="color: black;width: 142px;padding-bottom: 1px;text-align: center;font-size: 12pt;display: inline-block;border-bottom: 1px solid; "></p>(이하 "을" 이라고 칭함)은<br/>
					외주용역 업무( 이하 "프로젝트" 라고 칭함)을</span> 수행하기 위하여 상호 신의 성실의 원칙에 입각하여<br/>
					본 계약을 체결하고 그 증거로 2부를  작성하여 날인 후 각각 1부씩 보관합니다.
				</td> 
			</tr>  
			<tr>  
				<td colspan="14" height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-width: 1px 2px; border-style: solid; border-color: black black black black; height: 29px;">
					외주용역 프로젝트 수행에 대한 용역단가표
				</td> 
			</tr> 
			<tr id="multirowHeader">  
				<td height="29" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black; background: rgb(169, 208, 142); height: 29px;">
					구분
				</td>  
				<td colspan="6" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(169, 208, 142); border-right: 1px solid black;">
					기간
				</td>  
				<td colspan="2" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; background: rgb(169, 208, 142);">
					단가
				</td>  
				<td colspan="2" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-width: 1px; border-style: solid; border-color: black black black black; background: rgb(169, 208, 142);">
					투입공수
				</td>  
				<td colspan="3" 283" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-width: 1px 2px 1px 1px; border-style: solid; border-color: black black black black; background: rgb(169, 208, 142);">
					월 금액
				</td> 
			</tr> 
			<tr>  
				<td colspan="9" height="29" 838" style="border-left: 2px solid black; border-right: 1px solid black; height: 29px; width: 840px; font-weight: 700; " align="center">
					<p>합계 금액</p>
				</td>  
				<td 101" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; text-align: center; border: 1px solid black; color: black; font-size: 12pt; ">
					<p id="totalMM"></p>
				</td>  
				<td style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border: 1px solid black; color: black; font-size: 12pt; text-align: center;">
					M/M
				</td>  
				<td colspan="3" height="29" 283" style="border-right: 2px solid black; height: 29px;" align="left" valign="top">
					<p id="total2" style="font-size: 12pt;text-align: right;padding-right: 8px;"></p>
				</td> 
			</tr> 
			<tr>  
				<td rowspan="4" height="116" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 12pt; font-weight: 700; text-align: center; border-top: 1px solid black;  border-right: 1px solid black; border-left: 2px solid black; background: rgb(237, 125, 49); border-bottom: 1px solid black; height: 117px;">
					대금 지급조건
				</td>  
				<td colspan="5" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; font-size: 12pt; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(255, 242, 204); border-left: none;">
					&nbsp;법인&nbsp;
					<span id="chkPaymentContractCompany" >□</span><br/>  
					&nbsp;세금계산서 발행 후 익월 말일&nbsp;
				</td>  
				<td colspan="5" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-left: none;  color: black; font-size: 12pt; border-top: 1px solid black; border-bottom: 1px solid black; background: rgb(198, 224, 180);">
					&nbsp;일반사업자 / 개인&nbsp;
					<span id="chkPaymentContractPerson">□</span>  <br/>
					&nbsp;매월말일(용역) 종료  후 익월 15일&nbsp;
				</td>  
				<td colspan="3" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle;  border-left: none;  color: black; font-size: 12pt; border-top: 1px solid black; border-bottom: 1px solid black;  border-right: 2px solid black; background: rgb(180, 198, 231);">
					&nbsp;기타&nbsp;
					<span id="chkPaymentEtc" style="position: absolute; ">□</span><br/>
					<span id="etc"></span>
				</td>  
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: red; font-weight: 700; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; height: 29px; border-left: none;">
					&nbsp;※&nbsp;&nbsp;
				</td>  
				<td colspan="12" style="padding: 0px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: red; font-weight: 700; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					법인: 익월 말일 / 일반사업자 또는 개인: 익월 15일 / 그외: 기타란에 협의사항 기재 
				</td> 
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: red; font-weight: 700; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; height: 29px; border-left: none;">
					&nbsp;※&nbsp;&nbsp;
				</td>  
				<td colspan="12" style="padding: 0px 5px 0px 0px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: red; font-weight: 700; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					외주(사업소득)용역비 지급기준 : (근무일수/ 해당 월 일수_중도 시작일 또는 중도 종료일에 해당자는 해당 월 근무 일수로 일할 계산)*월 단가 후 천원미만 절사
				</td> 
			</tr> 
			<tr>  
				<td height="29" style="padding: 0px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: red; font-weight: 700; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; height: 29px; border-left: none;">
					&nbsp;※&nbsp;&nbsp;
				</td>  
				<td colspan="12" style="padding: 0px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: red; font-weight: 700; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					법인, 일반사업자는 부가세 별도 금액 / 개인은 사업소득세 3.3% 공제 전 금액
				</td> 
			</tr> 
			<tr>  
				<td colspan="14" height="33" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-bottom: 1px solid black;  color: black; font-size: 13pt; font-weight: 700; text-align: center; border-left: 2px solid black; background: rgb(217, 217, 217); border-right: 2px solid black; height: 33px;">
					뒷면에 계속 있습니다.
				</td> 
			</tr>
		</tbody>
	</table>
		
	<p style="page-break-before: always;"></p>
	<!-- 두번째 페이지 -->	
	 <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;" class="subpage"> 
      	<colgroup>
       		<col style="width: 14%"> 
       		<col style="width: 3%" >
			<col style="width: 83%" > 
		</colgroup>
		<tbody> 
			<tr>  
				<td colspan="3" height="33" style="padding: 0px; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-bottom: 1px solid black;  color: black; font-size: 13pt; font-weight: 700; text-align: center; border-left: 2px solid black; background: rgb(217, 217, 217); border-right: 2px solid black; height: 33px;">
					일반조건
				</td> 
			</tr> 
			<tr>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-bottom: none;  color: black; font-weight: 700; text-align: center; border-right: 1px solid black; border-left: 2px solid black;">
					제 1조<br/>(목적)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: none; border-left: 1px solid black; background: white; border-bottom: none;">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-left: none;  color: black; border-right: 2px solid black;">
					본 계약은 "갑"이 요청하는 외주용역 '프로젝트' 수행 업무에 대하여 "을"이 프로젝트 수행을 이행함에 있어 신의 성실의 원칙에 입각하여 이를 성실히 수행하고자 함에 그 목적이 있습니다.
				</td> 
			</tr> 
			<tr>  
				<td rowspan="2"  style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black; background: white;">
					제 2조  <br/>    (일반사항)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: 1px solid black; border-left: 1px solid black; background: white; border-bottom: none;">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: 1px solid black; background: white; border-right: 2px solid black; border-bottom: none; font-weight: bold;">
					'본 계약은 "을"의 독립성, 영리목적성, 계속반복성에 따라 "갑"과의 사용종속관계가 인정되지 않으므로
					외주용역 '프로젝트' 수행 계약서를 체결 하고, 고용노동부에 근로기준법을 적용을 받지 않음을 "을"은 합의합니다.
					<span name="signName" style="color: black; font-size: 11pt; text-decoration-line: underline;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(인)</span>
				</td> 
			</tr> 
			<tr>
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-right: none;  color: black; text-align: center; border-bottom: 1px solid black; border-left: 1px solid black;  ">
					②
				</td>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: blue; border-top: none; border-bottom: 1px solid black; background: white; border-right: 2px solid black; font-weight: bold;">
					'"을"은 "갑"의 취업규칙을 적용받지 않으며 복무관리규정에 따른 지휘감독 대상에 해당되지 않습니다. "을"은 "갑"이 요청하는 프로젝트 완료
					일정에 맞게 "을"이 수행하기로 한 프로젝트 과제에 대하여 일정 또는 과업범위를 준수하여야 하며, "갑"은 프로젝트 일정 또는 과업범위가
					원활하게 이루어지지 않을 경우 "을"에게 준수하도록 요구하고 그에 따른 시정조치를 취할 수 있습니다.
				</td> 
			</tr> 
			<tr>  
				<td rowspan="2" style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black black black;">
					제 3조 <br/>    (손해배상)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-bottom: none;  color: black; text-align: center; border-top: 1px solid black; border-left: 1px solid black; ">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-bottom: none; border-left: none;  color: black; border-top: 1px solid black; border-right: 2px solid black; ">
					본 계약의 해지 시 해지의 원인을 제공한 당사자는 (본계약에 따른 계약해지 단축) 손해배상의 책임에서 면책되지 아니하며, 본 계약의 불이행에
					의하여 발생한 손해에 대해서는 상대방에게 금전적인 손해배상의 책임이 있습니다.
				</td> 
			</tr> 
			<tr>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-right: none;  color: black; text-align: center; border-bottom: 1px solid black; border-left: 1px solid black;  ">
					②
				</td>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-left: none;  color: black; border-bottom: 1px solid black; border-right: 2px solid black; ">
					"갑"과 "을"은 본 계약과 관련하여 '프로젝트' 수행 중 알게 된 상대방의 인적, 기술적, 업무적인 사항에 대하여 기밀유지의 책임이 있습니다. 또한
					프로젝트 수행 중 고객사 정보를 유출 위반하는 경우 발생하는 유무형의 손해에 대한 배상의 책임이 있습니다. 
				</td> 
			</tr> 
			<tr>  
				<td rowspan="2" style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black black black;">
					제 4조<br/>    (수행범위 및<br/> 준수)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none; border-bottom: none;  color: black; text-align: center; border-top: 1px solid black; border-left: 1px solid black;">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-bottom: none; border-left: none;  color: black; border-top: 1px solid black; border-right: 2px solid black;">
					"갑"은 "을"이 수행하는 프로젝트의 일정과 범위에 대하여 조정이나 변동 또는 추가사항이 발생할 경우 이를 "을"에게 요구할 수 있으며 이에 대하여는
					"갑"과 "을"은 상호협의 하에 수행토록 합니다. "갑"의 요구사항은 "갑"의 지정된 담당자를 통하여 "을"에게 요구하며, "을"은 프로젝트 수행함에
					있어 조정이나 변경이 필요한 경우 그 내역 및 사유를 서면으로 "갑"에게 제시하여야 하며, "갑"의  사전 동의 하에 이를 조정 또는 변경할 수 있습니다.
				</td> 
			</tr> 
			<tr>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-right: none;  color: black; text-align: center; border-bottom: 1px solid black; border-left: 1px solid black; height: 30px;">
					②
				</td>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-left: none;  color: black; border-bottom: 1px solid black; border-right: 2px solid black;">
					"을"이 공급한 인력은 "갑"이 통보하는 장소에서 프로젝트를 수행해야 하는 책임이 있습니다. 
				</td> 
			</tr> 
			<tr>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black;">
					제 5조 <br/>    (대금지급조건)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black;">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					총 계약금액은 인력별 투입기간에 대한 용역단가표에 따라 1개월에 1회씩 정산 지급하며, 대금 지급방법은 세금계산서 발행 익월 말 지급을 원칙
					으로 합니다. 단, 일반사업자/개인은 익월 15일에 지급합니다. [월 기준으로 중도 시작 또는 중도 종료 대상자는 해당 월 근무 일수로
					일할계산/금액단위는 천원미만 절사]
				</td> 
			</tr> 
			<tr>  
				<td rowspan="3" style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black black black;">
					제 6조 <br/>    (계약의 해지)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: 1px solid black; border-bottom:  none; border-left: 1px solid black; ">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: 1px solid black; border-bottom: none; border-right: 2px solid black;">
					본 계약의 어느 당사자가 계약상 의무를 불이행하는 경우 상대방 당사자는 위반 당사자에 대하여 적정한 기간을 두어 위반의 시정을 최고할 수
					있고, 이러한 최고에도 불구하고 통지된 기간 내에 위반 상태가 시정되지 않는 경우 계약을 해지할 수 있습니다.
				</td> 
			</tr> 
			<tr>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: none; border-bottom: none; border-left: 1px solid black;">
					②
				</td>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: none; border-bottom: none; background: white; border-right: 2px solid black;">
					"을"이 수행하는 프로젝트에 대하여 원청과의 계약 해지, "갑"의 경영악화, 전염병(바이러스 질환 포함), 천재지변, 행정기관의 행정명령이나
					권고 등에 의해 조기 계약의 해지가 필요한 경우 "갑"은 "을"에게 3일 전에 통보하여 계약을 해지할 수 있습니다. 이 경우 "을"은 계약 해지에
					대하여 손해배상을 포함하여 어떠한 이의도 제기하지 않기로 합니다. <span name="signName" style="color: black; font-size: 11pt; text-decoration-line: underline;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(인)</span>
				</td> 
			</tr> 
			<tr>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: none; border-bottom: 1px solid black; border-left: 1px solid black;">
					③
				</td>  
				<td style="padding-top: 5px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: none; border-bottom: 1px solid black; background: white; border-right: 2px solid black;">
					제 6조 1항, 2항에 대한 사항으로 계약해지에 해당하거나, 별도 사유로 프로젝트 종료되었을 경우 "을"은 "갑"에게 프로젝트 수행 결과물을
					인수인계할 책임이 있습니다. 
				</td> 
			</tr> 
			<tr>  
				<td style="font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-size: 11pt; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black;">
					제 7조<br/>    (권리 의무의<br/>양도 금지)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; ">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					“갑”과 “을”은 서면으로 상대방의 동의를 얻지 아니한 경우, 본 계약서로부터 발생하는 권리 의무의 전부 또는 일부를 제 3자에게 양도하거나
					담보로 제공할 수 없습니다.
				</td> 
			</tr> 
			<tr>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black;">
					제 8조<br/>    (지적재산권)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; ">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					'"을"이 수행한 산출물에 대한 지적재산권을 포함한 모든 권리는 "갑"에게 귀속됩니다. 만약 관련 법령에 의하여 산출물의 발생 당시 "을"에게
					권리가  귀속되는 것으로 인정되는 경우 "을"은 본 계약에 따라 별도의 추가 의사표시 및 추가 대금 없이 해당 산출물에 대한 권리를 "갑"에게 양도합니다.  
				</td> 
			</tr> 
			<tr>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black;">
					제 9조<br/>    (관계규정의 <br/>    준용 및 해석)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; ">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					본 계약에 명시되지 아니한 사항, 추가합의가 요구되는 사항 또는 당사자 간의 견해차이에서 제기될 수 있는 분쟁의 방지를 위하여 쌍방은
					관계법령 및 일반 상관례에 따라우호적인 차원의 조정에 의한 합의에 우선 노력합니다. 
				</td> 
			</tr> 
			<tr>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle;  color: black; font-weight: 700; text-align: center; border-width: 1px 1px 1px 2px; border-style: solid; border-color: black;">
					제 10조<br/>    (합의관할)
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-right: none;  color: black; text-align: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; ">
					①
				</td>  
				<td style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-left: none;  color: black; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 2px solid black;">
					본 계약으로부터 발생하는 모든 분쟁은 “갑” 또는 “을”의 관할법원을 제1심 관할 법원으로 합니다. 
				</td> 
			</tr> 
			<tr>  
				<td colspan="3" height="18" style="padding: 0px; border-top: none; border-right: 2px solid black; border-left: 2px solid black; height: 19px;">
					<p><br/></p>
				</td>
			</tr>
			<tr>  
				<td colspan="3" height="18" style="padding: 0px; font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-right: 2px solid black;  color: black; text-align: center; border-left: 2px solid black; height: 19px;">
					<span id="today" style="font-weight: bold;"></span>
				</td>
			</tr>
			<tr>
				<td colspan="3" height="18" style="font-size: 11pt; font-family: '맑은 고딕', monospace; vertical-align: middle; border-top: none; border-right: none;  color: black; text-align: center; border-left: 2px solid black; height: 19px;">
					<span id="signName2" style="padding-right: 120px;"></span>
					㈜코비젼 대표이사 위장복 (인)
				</td>
			</tr>
		</tbody>
	</table>
</div>
</body>
<script type="text/javascript">
       //var bSelected = false;

       var formJson = opener.formJson;
       window.onload = function () {
       		document.getElementById("OrderNum").innerHTML = top.opener.getInfo("FormInstanceInfo.DocNo");

 	        var m_evalJSON = $.parseJSON(top.opener.document.getElementById("APVLIST").value);
 	        var taskInfo = $$(m_evalJSON).find("steps > division > step > ou > person > taskinfo[status='completed']");
 	        var LastDate = taskInfo.concat().eq(taskInfo.valLength()-1).attr("datecompleted");
 	        
 	        document.getElementById("OrderDate").innerHTML = LastDate.substring(0, 10);
 	        
 	        $("#today").text(LastDate.substring(0, 10).replace(/([0-9]{4})-([0-9]{2})-([0-9]{2})/, "$1년 $2월 $3일"));
 	        //$("#imgSeal").attr("src", top.opener.getUsingOfficialSeal());
 	       
 	        setBodyContext(top.opener.getInfo("BodyContext"));

           try {
               printDiv = printShow; 
               
               setTimeout(function(){
              	 window.print();
              	 setInterval('window.close()', '100');				// (2015-07-16 leesm) 크롬에서 print 팝업 페이지가 빨리 close되어 인쇄할 수 없으므로 추가함
              }, 300);
           	EASY.init();
           } catch (e) {
               alert(e.description);
           }
       }

       function printGo() {
           if (factory.printing == "undefined") {
               alert("브라우져 상단의 컨트롤 설치창을 확인해 주시기 바랍니다");
               return;
           }
           factory.printing.header = "";
           factory.printing.footer = "";
           factory.printing.portrait = true;
           factory.printing.leftMargin = 5.0;
           factory.printing.topMargin = 15.0;
           factory.printing.rightMargin = 5.0;
           factory.printing.bottomMargin = 15.0;
           factory.printing.Preview();
           factory.printing.Print(false, window);

           window.close();
       }
       function CloseLayer() {
           window.close();
       }

       function setBodyContext(sBodyContext) {
          
           try {
	           	var m_objJSON= $.parseJSON(sBodyContext);
	           
	            $("#phoneNumber").text( $$(m_objJSON).attr("accountPhone")); 
	            $("#contractName").text( $$(m_objJSON).attr("contractName"));
	            $("#OrderPriod").text( $$(m_objJSON).attr("SDATE") + " ~ " + $$(m_objJSON).attr("EDATE") );
	            $("#total").text( $$(m_objJSON).attr("totalAmount") );
	            $("#total1").text( NumToHangul1($$(m_objJSON).attr("totalAmount")) );
	            $("#total2").text($$(m_objJSON).attr("totalAmount") );
	            
	            $('#total').attr('data-pattern', 'currency');
	            $('#total2').attr('data-pattern', 'currency');
	            
            	if ($$(m_objJSON).attr("moneySelect") == 0) {
                   $("#chkPaymentContractCompany").text("■"); //세금계산서 발행 후 익월 말일
               } else if ($$(m_objJSON).attr("moneySelect") == 1) {
            	   $("#chkPaymentContractPerson").text("■");  //매월말일(용역) 종료  후 익월 15일
               } else {
            	   $("#chkPaymentEtc").text("■");			//기타 
            	   
            	   if($$(m_objJSON).attr("etc") != undefined && $$(m_objJSON).attr("etc") != ""){
	            	   $("#etc").text("(" + $$(m_objJSON).attr("etc") + ")"); 
            	   }
               }
	            
            	var signName = '', signName2 = '';
            	
	            if($$(m_objJSON).attr("contractGubun") == "0"){	//법인
	            	//signName = $$(m_objJSON).attr("ceo");
	            	signName = $$(m_objJSON).attr("contractCompany"); // 법인인 경우 대표명이 아닌, 회사명 들어가도록 수정
	            	signName2 = signName + " 대표이사 " + $$(m_objJSON).attr("ceo");
	            	
	                $("#chkContractCompany").text("■");
	            
	            	$("#companyName").text($$(m_objJSON).attr("contractCompany")); //회사명
	            	$("#ceoName").text($$(m_objJSON).attr("ceo")); // 대표이사 / 성명(일반사업자/개인)
	            	$("#Address").text($$(m_objJSON).attr("adress")); // 주소
	            }else if($$(m_objJSON).attr("contractGubun") == "1"){ //개인
	            	signName = $$(m_objJSON).attr("contractPerson");
	            	signName2 = "성명: " + signName;
	            	
	            	$("#chkContractPerson").text("■");
	            
	            	$("#ceoName").text($$(m_objJSON).attr("contractPerson")); 	// 대표이사 / 성명(일반사업자/개인)
	            	$("#IDNumber").text($$(m_objJSON).attr("idCard1") + " - " + $$(m_objJSON).attr("idCard2")); 	// 주민등록번호
	            	$("#Address").text($$(m_objJSON).attr("adress")); // 주소
	            }else{	//개인 사업자
	            	signName = $$(m_objJSON).attr("contractPerson");
	            	signName2 = "성명: " + signName;
	            	
	            	$("#chkContractPerson2").text("■");
	            
	            	$("#ceoName").text($$(m_objJSON).attr("contractPerson")); 	// 대표이사 / 성명(일반사업자/개인)
	            	$("#IDNumber").text($$(m_objJSON).attr("idLicensee1") + " - " + $$(m_objJSON).attr("idLicensee2") + " - " + $$(m_objJSON).attr("idLicensee3")); 	// 주민등록번호
	            	$("#Address").text($$(m_objJSON).attr("adress")); // 주소
	            }
	            
            	$("p[name='signName']").text(signName);
				$("#signName2").text(signName2 + " (인)"); // 을의 회사명+대표이사명 or 성명
            	
            	if($$(m_objJSON).attr("contractGubun") == "0"){	//법인
            		$("span[name='signName']")[0].innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + $$(m_objJSON).attr("ceo") + "&nbsp;&nbsp;&nbsp;(인)";
            		$("span[name='signName']")[1].innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + $$(m_objJSON).attr("ceo") + "&nbsp;&nbsp;&nbsp;(인)";
            	}
            	else {
            		$("span[name='signName']")[0].innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + signName+ "&nbsp;&nbsp;&nbsp;(인)";
            		$("span[name='signName']")[1].innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + signName+ "&nbsp;&nbsp;&nbsp;(인)";
            	}
            	
	
	            //multirow 별도 처리
	            if (typeof opener.formJson.BodyContext.tblAdd2 != 'undefined' && opener.formJson.BodyContext.tblAdd2 != "") {
	            	 addMultiRowLine(opener.formJson.BodyContext.tblAdd2, opener.formJson.BodyContext.contractPerson);
	            }

               //required
               EASY.init();
           }
           catch (e) { }
       }

       function addMultiRowLine(tbID) { //멀티로우
           var sHtml = "";
       	   var totalmm = 0;
           var number, sDate, eDate, unitPrice, mm,  total; // 구분, 기간, 단가 , 공수, 월 금액
          
           
           if (tbID.length == undefined) { //한줄일 경우 
        	    number = 1; 
           		sDate = tbID.SPeriod;
           		eDate = tbID.EPeriod;
           		unitPrice = tbID.unitPrice;
           		mm = tbID.mm;
           		total = tbID.total;
           		
           		totalmm += parseFloat(mm);
           		
           		sHtml += '<tr>';
           		sHtml += '<td height="29" style="font-family: \'맑은 고딕\', monospace;vertical-align: middle;font-size: 12pt; text-align: center;border-width: 1px 1px 1px 2px;border-style: solid;">1</td>';
           		sHtml += '<td colspan="6" style="font-size: 12pt;font-family: \'맑은 고딕\', monospace; text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">';
           		sHtml += 			sDate + " ~ " + eDate;
           		sHtml += '	</td>';
           		sHtml += '<td colspan="2" data-pattern="currency" style="padding-right: 8px;font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: right;border-bottom: 1px solid black;">';
           		sHtml +=  			unitPrice;
           		sHtml += '</td>';
           		sHtml += '<td 101" style="font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: center;border: 1px solid black;">';
           		sHtml += 			mm;
           		sHtml += '</td>';  
           		sHtml += '<td style="font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: center;border: 1px solid black;">M/M</td>';  
           		sHtml += '<td colspan="3" 283" data-pattern="currency" style="padding-right: 8px;font-family: \'맑은 고딕\', monospace; color: black;font-size: 12pt;text-align: right;border-width: 1px 2px 1px 1px;border-style: solid;">';
           		sHtml += 			total;
           		sHtml += '</td>';
           		sHtml += '</tr>';
           		
           }else {
               for (var i = 0; i < tbID.length; i++) {
            	    number = i + 1; 
               		sDate = tbID[i].SPeriod;
               		eDate = tbID[i].EPeriod;
               		unitPrice = tbID[i].unitPrice;
               		mm = tbID[i].mm;
               		total = tbID[i].total;

               		totalmm += parseFloat(mm);
               		
               		sHtml += '<tr>';
               		sHtml += '<td height="29" style="font-family: \'맑은 고딕\', monospace;vertical-align: middle;font-size: 12pt; text-align: center;border-width: 1px 1px 1px 2px;border-style: solid;">' + number + '</td>';
               		sHtml += '<td colspan="6" style="border-bottom: text-align:center; ont-size: 13pt;font-family: \'맑은 고딕\', monospace; text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">';
               		sHtml += 			sDate + " ~ " + eDate;
               		sHtml += '	</td>';  
               		//sHtml += '<td style="/* padding: 0px; */font-family: \'맑은 고딕\', monospace; font-size: 12pt; text-align: center; border-bottom: 1px solid black;">~</td>';  
               		//sHtml += '<td colspan="2" style="font-family: \'맑은 고딕\', monospace; font-size: 12pt; text-align: center; border-bottom: 1px solid black;border-right: 1px solid black;">';
               		//sHtml += 			eDate;
               		//sHtml += '</td>';  
               		sHtml += '<td colspan="2" data-pattern="currency" style="padding-right: 8px;font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: right;border-bottom: 1px solid black;">';
               		sHtml +=  			unitPrice;
               		sHtml += '</td>';
               		sHtml += '<td 101" style="font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: center;border: 1px solid black;">';
               		sHtml += 			mm;
               		sHtml += '</td>';  
               		sHtml += '<td style="font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: center;border: 1px solid black;">M/M</td>';  
               		sHtml += '<td colspan="3" data-pattern="currency" style="padding-right: 8px;font-family: \'맑은 고딕\', monospace; color: black;font-size: 12pt;text-align: right;border-width: 1px 2px 1px 1px;border-style: solid;">';
               		sHtml += 			total;
               		sHtml += '</td>';
               		sHtml += '</tr>';
               }
           }

           // 12줄로 고정해서 출력함.
           var cnt = 12-number;
           for (var i = 0; i < cnt; i++) {
       	   		number++; 
          		
          		sHtml += '<tr>';
          		sHtml += '<td height="29" style="font-family: \'맑은 고딕\', monospace;vertical-align: middle;font-size: 12pt; text-align: center;border-width: 1px 1px 1px 2px;border-style: solid;">' + number + '</td>';
          		sHtml += '<td colspan="6" style="border-bottom: text-align:center; ont-size: 13pt;font-family: \'맑은 고딕\', monospace; text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;"> ~ </td>';
          		sHtml += '<td colspan="2" data-pattern="currency" style="padding-right: 8px;font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: right;border-bottom: 1px solid black;"></td>';
          		sHtml += '<td 101" style="font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: center;border: 1px solid black;"></td>';  
          		sHtml += '<td style="font-family: \'맑은 고딕\', monospace; font-size: 12pt;text-align: center;border: 1px solid black;">M/M</td>';  
          		sHtml += '<td colspan="3" data-pattern="currency" style="padding-right: 8px;font-family: \'맑은 고딕\', monospace; color: black;font-size: 12pt;text-align: right;border-width: 1px 2px 1px 1px;border-style: solid;"></td>';
          		sHtml += '</tr>';
          }
           
           $("#multirowHeader").after(sHtml);
           $("#totalMM").text(totalmm.toFixed(2));
       }
       

       // 숫자를 한글로 변환
       function NumToHangul1(chknum) {
           chknum = chknum.split(".")[0];
           var isMinus = false;

           if (chknum.indexOf('-') > -1) {
               chknum = chknum.substring(1, chknum.length);
               isMinus = true;
           }

           val = chknum;
           var won = new Array();
           re = /^[1-9][0-9]*$/;
           num = val.toString().split(',').join('');

           if (!re.test(num)) {
               return '0';
           }
           else {
               var price_unit0 = new Array('', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구');
               var price_unit1 = new Array('', '십', '백', '천');
               var price_unit2 = new Array('', '만', '억', '조', '경', '해', '시', '양', '구', '간', '정');
               for (i = num.length - 1; i >= 0; i--) {
                   won[i] = price_unit0[num.substr(num.length - 1 - i, 1)];
                   if (i > 0 && won[i] != '') {
                       won[i] += price_unit1[i % 4];
                   }
                   if (i % 4 == 0) {
                       won[i] += price_unit2[(i / 4)];
                   }
               }
               for (i = num.length - 1; i >= 0; i--) {
                   if (won[i].length == 2) won[i - i % 4] += '-';
                   if (won[i].length == 1 && i > 0) won[i] = '';
                   if (i % 4 != 0) won[i] = won[i].replace('일', '');
               }

               won = won.reverse().join('').replace(/-+/g, '');

               if (won.toString().substr(0, 1) == '십') {
                   won = '일' + won;
               }

               if (isMinus){
                   return '-' + won;
               } else {
                   //return "&nbsp;&nbsp;&nbsp;일금 " + won + " 원정";
                   return won;
               }
           }
       }
</script>