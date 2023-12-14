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
<!-- 라인선스 인증서 발급 품의서 인쇄 양식   -->

<!-- 양식개선 새 컴포넌트 모음 -->
<link type="text/css" rel="stylesheet" href="<%=cssPath%>/approval/css/xeasy/xeasy.0.9.css<%=resourceVersion%>" />
<script type="text/javascript" src="resources/script/xeasy/xeasy-number.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/xeasy/xeasy-numeral.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/xeasy/xeasy-timepicker.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/xeasy/xeasy.multirow.0.9.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="resources/script/xeasy/xeasy4j.0.9.2.js<%=resourceVersion%>"></script>

<style>
.defaultInfo>strong, .defaultInfo>span{
	font-size: 11pt;
	font-weight: bold;
	line-height: 30px;
}
/* .pageContainer:after{
	background-image:url(/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.png);
    top:500px;
    left:110px;
    position:absolute;
    background-size:100%;
    opacity:0.1!important;
    filter:alpha(opacity=10);
    z-index:-1;
    content:"";
    width:80%;
    height:100%;
    background-repeat: no-repeat;
	
} */

.background {
  height: 100%; /*can be anything*/
  width: 95%; /*can be anything*/
  z-index:-1;
  position: fixed;
}
.background img {
/*   max-height: 100%;
  max-width: 100%;
  width: auto;
  height: auto; */
  width:90%;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  opacity:0.2;
  margin: 440px auto auto auto;
}

</style>

<body style="line-height:20px; " >
    <div id="printShow" style="padding:30px 30px 0px 30px; background-position: center; ">
    <!--style="width: 100%; height:100%; position: absolute; top:0px; left:0px; z-index: 0; text-align: center; vertical-align: middle;"   -->
    	<div class="background" >
	    	<img  alt="logo" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.png"  />
    	</div>
	    <div>
	    	<img  alt="logo" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.png" align="left" style="width: 140px; margin-bottom: 10px; /* opacity: 0.4; */" />
	    </div>
        <div class="pageContainer" style="border: 1px solid rgb(0, 0, 0);  width: 100%;  height: calc(100% - 100px); clear: both; position: relative;">
	        <div  style="padding: 70px 10px 10px;">
			      	<div style="width: 100%; text-align: center; margin-bottom:100px;">
			        		 <span id="mainSubject" style="font-size: 20pt; text-align: center; font-weight: bold">소프트웨어 라이선스 사용 인증서</span><%-- id="title"--%>
			        </div>
		            <div class="defaultInfo" >
		           		 <span id="lang_Customer"><strong style="letter-spacing: 7px;">고객사</strong></span><span>:&nbsp;</span>
		           		 <span id="customer"></span>
		            </div>
		            <div class="defaultInfo">
		           		  <span id="lang_Contract"><strong style="letter-spacing: 7px;">계약명</strong></span><span>:&nbsp;</span>
		           		 <span id="contract"></span>
		            </div>
		            <div class="defaultInfo">
		           		  <span id="lang_SerialNumber"><strong>인증번호</strong></span><span>:&nbsp;</span>
		           		  <span id="SerialNumber"></span>
		            </div>
		            <div class="defaultInfo">
		           		  <span id="lang_Date"><strong style="letter-spacing: 7px;">발행일</strong></span><span>:&nbsp;</span>
		           		  <span id="day"></span>
		            </div>
		            <div class="defaultInfo">
		           		   <span id="lang_Product"><strong style="float: left;">제품명 및 사용자 수:&nbsp;</strong></span>
		           		  <table id="SubTable1" style="float: left; margin-top:4px;" class="multi-row-table" cellpadding="0" cellspacing="0">
				                <tr class="multi-row-template">
				                    <td><span name="Product_Name"></span>&nbsp;</td>
				                </tr>
				          </table>
		            </div>
		
					<div	id="mainContents"  style="text-align: justify; font-size: 11pt; line-height: 190%; padding-top:80px; clear:both;">
						이 소프트웨어가 제공하는 프로그램에 대하여 위의 제품번호가 부여된 사용자 혹은 단체에게 <br>
						사용권을 드립니다. <br>
						이 소프트웨어에 포함된 프로그램은 저작권법과 국제 저작권 조항에 의하여 보호 받고 있습니다.  <br>
						이 소프트웨어의 사용 및 권한과 관련된 모든 사항은 소프트웨어를 구매한 본 계약서의 <br>
						내용에 따릅니다.  <br>
						이 소프트웨어 사용권 증서는 제품을 구입한 증거이며 업그레이드나 서비스를 받을 경우 <br>
						필요하오니 안전한 장소에 보관하시기 바랍니다.  <br>
					</div>
					<div  style="font-size: 16pt; position: absolute; bottom: 75px; width:100%" align="center" >
						<div style="display: inline; position: relative;">
							<img  alt="logo" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.png" style="width: 140px; margin-bottom: 5px; " />
							<strong style="margin-right: 95px;" name="companyCEO">㈜코비젼 대표이사 위장복</strong>
							<img id="sealImage" style="width: 90px; height: 90px; right: 0px; bottom: -15px; position: absolute; z-index: 99;" >
						</div>
					</div>
	        </div>
			<div  style="width: 100%; bottom: 0px; line-height: 28px; font-size: 9pt; padding:10px; border-top: 1px solid #000000; background-color: rgb(242, 242, 242); position: absolute;  " align="center"  >
				<strong name="companyInfo">
					㈜코비젼 (우)07794 서울시 강서구 마곡중앙8로 7길 11 (마곡동) 디앤씨캠퍼스  <br>
					대표 : 02-6965-3100  I FAX : 02-6965-3200 I  www.covision.co.kr
				</strong>
			</div>
           	<!-- <img id="sealImage" style="left: 580px; top: 1118px; width: 100px; height: 100px; position: absolute;"> -->
        </div>

		<div style="page-break-before: always; padding-top:30px;">
	    	<img  alt="logo" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.png" align="left" style="width: 140px; margin-bottom: 10px; /* opacity: 0.4; */" />
	    </div>
		<div class="pageContainer" style="border: 1px solid rgb(0, 0, 0);  width: 100%;  height: calc(100% - 100px); clear: both; position: relative;">
			<div  style="padding: 10px;">
			   	<div style="width: 100%; text-align: center; margin-top: 10px; margin-bottom: 30px;">
		        		 <span id="subSubject" style="font-size: 20pt; text-align: center; font-weight: bold" >㈜코비젼 소프트웨어 라이선스 계약서</span>
		        </div>
		        <div id="subContents">
	            	<div  style="text-align: justify; line-height: 22px; font-size: 10pt;">
	            			이 계약은 ㈜코비젼과 사용자 사이의 법적인 사용 허가 계약으로서 매매 계약이 아닙니다. 사용자가 
							프로그램을 설치하는 것은 이 계약 내용에 대하여 동의함을 인정하는 것입니다. <br>
							<b>1. 사용권:</b> <br>
							<div style="margin-left:7px;">
								㈜코비젼은 사용권 증서의 내용대로 이 소프트웨어를 사용할 권리를 드립니다. 이 소프트웨어의 사용자 
								수는 라이선스 구매 수량을 지칭하며 등록된 사용자 수 (Named User)를 뜻합니다. 
							</div>
							<b>2. 사용권의 이전: </b>
							<div style="margin-left:7px;">
								사용자가 기존제품에서 Upgrade하여 이 소프트웨어를 구입한 경우 기존제품의 사용권은 Upgrade판으로 
								옮겨지지만, 기존제품을 Upgrade판과 동일한 시간에 실행하지 않는다는 전제하에서 기존 제품을 사용할 
								수 있습니다. 따라서 기존제품의 양도, 대여 및 판매는 금지되며, Upgrade판에서 기존제품에 부속된 
								별도의 소프트웨어나 사용자 프로그램(utilities)의 사용권을 계속 유지 합니다. 
							</div>
							<b>3. 저작권: </b>
							<div style="margin-left:7px;">
								이 소프트웨어와 모든 부속물에 대한 저작권과 지적 소유권은 ㈜코비젼이 가지고 있으며, 이 권리는 
								대한민국의 저작권법과 국제 저작권 조약으로 보호 받습니다. 따라서 사용자는 이 소프트웨어를 
								사용하거나 보관용 복사본 하나를 만드는 것 이외에는 더 이상의 복사를 할 수 없습니다. 또한 ㈜코비젼의
								사전 서면 동의 없이 부속된 인쇄물을 수정, 변형 및 복사할 수 없습니다.
							</div>
							<b>4. 책임: </b> 
							<div style="margin-left:7px;">
								㈜코비젼을 제외한 ㈜코비젼의 제품 공급자, 대리점을 포함한 제 3자가 구두, 문서 및 기타 고지 수단을 
								이용하여 사용자에게 한 약속에 대해, ㈜코비젼은 책임을 지지 않습니다. 
							</div>
							<b>5. 기간: </b> 
							<div style="margin-left:7px;">
								본 계약은 종료될 때까지 유효하지만, 사용자가 프로그램과 그 부속물 및 보관 본을 파기하거나 계약 
								내용을 준수하지 않는 경우에 종료될 수 있습니다.
							</div>
							<b>6. 사용자 등록 및 개정 방침: </b>
							<div style="margin-left:7px;">
								구입한 소프트웨어에 대한 고객 지원을 받거나 개정판에 대한 혜택을 얻기 위해서 개인 또는 단체 사용자는
								반드시 ㈜코비젼의 SCC (Smart Care Center)에 등록 하셔야 합니다.  ㈜코비젼은 고객 등록을 마친 사용자에
								한해서 고객 지원을 하며, 개정판을 할인 가격에 제공하여 드립니다. 
							</div>
							<b>7. 고객 지원: </b>
							<div style="margin-left:7px;">
								㈜코비젼은 고객 등록을 한 사용자에 한하여 관련 소프트웨어를 사용할 수 있는 시스템 환경에서 발생한 
								문제에 대한 기술적인 문의에 대하여 해결책을 제공하고자 최선을 다하며, 사용불편에 따른 신고에 대한 
								결과 통보에도 최선을 다합니다. 
							</div>
							<b>8. 인정: </b>
							<div style="margin-left:7px;">
								귀하는 이 사용계약서에 명시된 모든 내용을 읽고 이해하며, 계약 조건에 동의하고 나아가 이 내용이 옛 
								판의 사용계약서나 과거의 모든 주문, 약속, 광고, 고지 또는 서면 합의 사항에 우선하는 것을 인정합니다. 
							</div>
							<b>9. 문의: </b>
							<div style="margin-left:7px;">
								이 계약서에 대하여 의 문 사항이 있으면, ㈜코비젼에 전화, 팩스, 온라인, 서신 등을 통하여
								연락하여 주십시오.
							</div>
	            	</div>
		        </div>
          		<div  style="font-size: 16pt; position: absolute; bottom: 75px; width:100%" align="center" >
					<div style="display: inline; position: relative;;">
						<img  alt="logo" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.png" style="width: 140px; margin-bottom: 5px; " />
						<strong  name="companyCEO">㈜코비젼 대표이사 위장복</strong>
					</div>
				</div>
			</div>
			<div  style="width: 100%; bottom: 0px; line-height: 28px; font-size: 9pt; padding:10px; border-top: 1px solid #000000; background-color: rgb(242, 242, 242); position: absolute;  " align="center"  >
				<strong name="companyInfo">
					㈜코비젼 (우)07794 서울시 강서구 마곡중앙8로 7길 11 (마곡동) 디앤씨캠퍼스  <br>
					대표 : 02-6965-3100  I FAX : 02-6965-3200 I  www.covision.co.kr
				</strong>
			</div>
		</div>
    </div>
</body>

<script type="text/javascript">
		var m_objJSON; //bodyContenxt
        window.onload = function () { setInitioration(); }
        
        /*
        {
        		"ko":{
          		  "page1":{
          		    "Subject": "소프트웨어 라이선스 사용 인증서",
          		    "CustomerFieldName" : "<strong style='letter-spacing: 7px;'>고객사</strong>",
          		    "ConTitleFieldName" : " <strong style='letter-spacing: 7px;'>계약명</strong>",
          		    "SerialNumberFieldName" : "<strong>인증번호</strong>",
          		    "DateFieldName": "<strong style='letter-spacing: 7px;'>발행일</strong>",
          		    "ProductFieldName": "<strong style='float: left;'>제품명 및 사용자 수:&nbsp;</strong>",
          		    "Content": "
  						이 소프트웨어가 제공하는 프로그램에 대하여 위의 제품번호가 부여된 사용자 혹은 단체에게 <br>
  						사용권을 드립니다. <br>
  						이 소프트웨어에 포함된 프로그램은 저작권법과 국제 저작권 조항에 의하여 보호 받고 있습니다.  <br>
  						이 소프트웨어의 사용 및 권한과 관련된 모든 사항은 소프트웨어를 구매한 본 계약서의 <br>
  						내용에 따릅니다.  <br>
  						이 소프트웨어 사용권 증서는 제품을 구입한 증거이며 업그레이드나 서비스를 받을 경우 <br>
  						필요하오니 안전한 장소에 보관하시기 바랍니다.  <br>"
          		  },
          		  "page2":{
          		     "Subject": "㈜코비젼 소프트웨어 라이선스 계약서",
          		     "Content": "<div  style='text-align: justify; line-height: 22px; font-size: 10pt;'>이 계약은 ㈜코비젼과 사용자 사이의 법적인 사용 허가 계약으로서 매매 계약이 아닙니다. 사용자가 
  						프로그램을 설치하는 것은 이 계약 내용에 대하여 동의함을 인정하는 것입니다. <br>
  						<b>1. 사용권:</b> <br>
  						<div style='margin-left:7px;'>
  							㈜코비젼은 사용권 증서의 내용대로 이 소프트웨어를 사용할 권리를 드립니다. 이 소프트웨어의 사용자 
  							수는 라이선스 구매 수량을 지칭하며 등록된 사용자 수 (Named User)를 뜻합니다. 
  						</div>
  						<b>2. 사용권의 이전: </b>
  						<div style='margin-left:7px;'>
  							사용자가 기존제품에서 Upgrade하여 이 소프트웨어를 구입한 경우 기존제품의 사용권은 Upgrade판으로 
  							옮겨지지만, 기존제품을 Upgrade판과 동일한 시간에 실행하지 않는다는 전제하에서 기존 제품을 사용할 
  							수 있습니다. 따라서 기존제품의 양도, 대여 및 판매는 금지되며, Upgrade판에서 기존제품에 부속된 
  							별도의 소프트웨어나 사용자 프로그램(utilities)의 사용권을 계속 유지 합니다. 
  						</div>
  						<b>3. 저작권: </b>
  						<div style='margin-left:7px;'>
  							이 소프트웨어와 모든 부속물에 대한 저작권과 지적 소유권은 ㈜코비젼이 가지고 있으며, 이 권리는 
  							대한민국의 저작권법과 국제 저작권 조약으로 보호 받습니다. 따라서 사용자는 이 소프트웨어를 
  							사용하거나 보관용 복사본 하나를 만드는 것 이외에는 더 이상의 복사를 할 수 없습니다. 또한 ㈜코비젼의
  							사전 서면 동의 없이 부속된 인쇄물을 수정, 변형 및 복사할 수 없습니다.
  						</div>
  						<b>4. 책임: </b> 
  						<div style='margin-left:7px;'>
  							㈜코비젼을 제외한 ㈜코비젼의 제품 공급자, 대리점을 포함한 제 3자가 구두, 문서 및 기타 고지 수단을 
  							이용하여 사용자에게 한 약속에 대해, ㈜코비젼은 책임을 지지 않습니다. 
  						</div>
  						<b>5. 기간: </b> 
  						<div style='margin-left:7px;'>
  							본 계약은 종료될 때까지 유효하지만, 사용자가 프로그램과 그 부속물 및 보관 본을 파기하거나 계약 
  							내용을 준수하지 않는 경우에 종료될 수 있습니다.
  						</div>
  						<b>6. 사용자 등록 및 개정 방침: </b>
  						<div style='margin-left:7px;'>
  							구입한 소프트웨어에 대한 고객 지원을 받거나 개정판에 대한 혜택을 얻기 위해서 개인 또는 단체 사용자는
  							반드시 ㈜코비젼의 SCC (Smart Care Center)에 등록 하셔야 합니다.  ㈜코비젼은 고객 등록을 마친 사용자에
  							한해서 고객 지원을 하며, 개정판을 할인 가격에 제공하여 드립니다. 
  						</div>
  						<b>7. 고객 지원: </b>
  						<div style='margin-left:7px;'>
  							㈜코비젼은 고객 등록을 한 사용자에 한하여 관련 소프트웨어를 사용할 수 있는 시스템 환경에서 발생한 
  							문제에 대한 기술적인 문의에 대하여 해결책을 제공하고자 최선을 다하며, 사용불편에 따른 신고에 대한 
  							결과 통보에도 최선을 다합니다. 
  						</div>
  						<b>8. 인정: </b>
  						<div style='margin-left:7px;'>
  							귀하는 이 사용계약서에 명시된 모든 내용을 읽고 이해하며, 계약 조건에 동의하고 나아가 이 내용이 옛 
  							판의 사용계약서나 과거의 모든 주문, 약속, 광고, 고지 또는 서면 합의 사항에 우선하는 것을 인정합니다. 
  						</div>
  						<b>9. 문의: </b>
  						<div style='margin-left:7px;'>
  							이 계약서에 대하여 의 문 사항이 있으면, ㈜코비젼에 전화, 팩스, 온라인, 서신 등을 통하여
  							연락하여 주십시오.</div>
              	</div>"
          		  },
          		  "footer":{
          		    "CompanyCEO": "㈜코비젼 대표이사 위장복",
          		    "CompanyInfo": "㈜코비젼 (우)07794 서울시 강서구 마곡중앙8로 7길 11 (마곡동) 디앤씨캠퍼스  <br>
  					대표 : 02-6965-3100  I FAX : 02-6965-3200 I  www.covision.co.kr"
          		  }
          		},
          		"en":{
          		  "page1":{
          		    "Subject": "Software license usage certificate",
          		    "CustomerFieldName" : "<strong>Customer</strong>",
          		    "ConTitleFieldName" : " <strong>Contract title</strong>",
          		    "SerialNumberFieldName" : "<strong>Certificate number</strong>",
          		    "DateFieldName": "<strong>Date of issue</strong>",
          		    "ProductFieldName": "<strong style='float: left;'>Product title & the number of users:&nbsp</strong>",
          		    "Content": "User or a group with the product number above has the right to facilitate the program provided by the software. <br>
  						Program included in the software is protected by the copyright law and the ordinances on international copyright. <br>
  						All sorts of contents related to usage and authorization of this software is according to the contents of this agreement after purchasing the software. <br>
  						This software usage right certificate works as a proof of purchasing the product, and should be kept in a secured place since it may be required in upgrades and other services. <br>"
          		  },
          		  "page2":{
          		     "Subject": "COVISION Corp. software license agreement",
          		     "Content": "<div  style='text-align: justify; line-height: 20px; font-size: 9pt;'>
              			This agreement is the legal agreement on usage permission between COVISION Corp.
              			 and the user, and is not the sales agreement. Installation of the program means that the user agrees to the contents of this agreement.<br>
  						<b>1. Usage right:</b>
  						<div style='margin-left:7px;'>
  							COVISON Corp. offers the usage right on this software, shown as the contents of the usage right certificate. 
  							The number of users under this software is the license purchase amount, which is also equivalent to the number of named users.
  						</div>
  						<b>2. Transfer of the usage right:</b>
  						<div style='margin-left:7px;'>
  							If the user purchases this software by upgrading the existing product, the usage right of the existing product is shifted toward the upgraded version. 
  							The existing product may be used further, unless it is run at the same time with the upgraded version. Transfer, rent and sales on the existing product is therefore prohibited. 
  							Usage right on the separate software attached to the existing product or on the user utilities, in the upgraded version, is maintained. 
  						</div>
  						<b>3. Copyright:</b>
  						<div style='margin-left:7px;'>
  							All sorts of copyrights and intellectual ownerships on this software and other attachments are owned by COVISION Corp. 
  							This right is protected by the copyright law of the Republic of Korea, and the international copyright treaty.
  							Therefore, the user cannot create a copy of this software, beside using it or making the copy for storage. 
  							Other attached printed documents cannot be revised, modified or copied unless there is an agreement in advance in writing by COVISION Corp.
  						</div>
  						<b>4. Responsibility:</b> 
  						<div style='margin-left:7px;'>
  							COVISION Corp. is not responsible for all the pledges from the 3rd Party, including the product supplier and agencies of COVISION Corp. 
  							and except COVISION Corp. itself, to the users through verbally, in writing or other methods or certain notification
  						</div>
  						<b>5. Period:</b> 
  						<div style='margin-left:7px;'>
  							This agreement is valid till its expiration If the user damages the program, its attachments or its stored copy, 
  							or if the user does not comply with the agreement contents, the agreement may be cancelled in advance. 
  						</div>
  						<b>6. User registration & revision policy:</b>
  						<div style='margin-left:7px;'>
  							To have the customer support on the purchased software, or to have benefit on the revised edition, 
  							an individual or a group user should be registered onto the Smart Care Center (SCC) of COVISION Corp. 
  							COVISION Corp. only provides customer support for the users after completing the customer registration, 
  							and also provides the revised edition with a discounted price. 
  						</div>
  						<b>7. Customer support:</b>
  						<div style='margin-left:7px;'>
  							COVISION Corp. will make its best effort in providing the solution for technical requests occurred on the potential system environments that uses this software,
  							 towards the users after completing the customer registration. 
  							 COVISION Corp. will also make its best effort in reporting the corresponding result from claims and complaints based on user inconvenience. 
  						</div>
  						<b>8. Recognition:</b>
  						<div style='margin-left:7px;'>
  							Customer should note that all sorts of contents described in this usage agreement are read and clearly understood. 
  							Customer also agrees to the agreement condition, and further agrees that these contents are prioritized against the usage agreements from the older editions, 
  							and against all orders, pledges, advertisements, notifications or agreements in writing in the past. 
  						</div>
  						<b>9. Inquiry: </b>
  						<div style='margin-left:7px;'>
  							If you have an inquiry on this agreement, please contact COVISION Corp. through telephone, fax, online, or in writing. 
  						</div>
              	</div>"
          		  },
          		  "footer":{
          		    "CompanyCEO": "COVISION Corp. CEO Wui Jang Bok",
          		    "CompanyInfo": "11, Magok Jung-ang-8-ro 7-gil, Gangseo-gu, Seoul / Zip code: 07794  <br>
  					TEL: 02-6965-3100 / FAX: 02-6965-3200 / www.covision.co.kr"
          		  }
          		}
          }
        
        */
        
        var dicContents = {
        		"ko":{
          		  "page1":{
          		    "Subject": "소프트웨어 라이선스 사용 인증서",
          		    "CustomerFieldName" : "<strong style='letter-spacing: 7px;'>고객사</strong>",
          		    "ConTitleFieldName" : " <strong style='letter-spacing: 7px;'>계약명</strong>",
          		    "SerialNumberFieldName" : "<strong>인증번호</strong>",
          		    "DateFieldName": "<strong style='letter-spacing: 7px;'>발행일</strong>",
          		    "ProductFieldName": "<strong style='float: left;'>제품명 및 사용자 수:&nbsp;</strong>",
          		    "Content": "이 소프트웨어가 제공하는 프로그램에 대하여 위의 제품번호가 부여된 사용자 혹은 단체에게 <br>사용권을 드립니다. <br>이 소프트웨어에 포함된 프로그램은 저작권법과 국제 저작권 조항에 의하여 보호 받고 있습니다.  <br>이 소프트웨어의 사용 및 권한과 관련된 모든 사항은 소프트웨어를 구매한 본 계약서의 <br>내용에 따릅니다.  <br>이 소프트웨어 사용권 증서는 제품을 구입한 증거이며 업그레이드나 서비스를 받을 경우 <br>필요하오니 안전한 장소에 보관하시기 바랍니다.  <br>"
          		  },
          		  "page2":{
          		     "Subject": "㈜코비젼 소프트웨어 라이선스 계약서",
          		     "Content": "<div  style='text-align: justify; line-height: 22px; font-size: 10pt;'>이 계약은 ㈜코비젼과 사용자 사이의 법적인 사용 허가 계약으로서 매매 계약이 아닙니다. 사용자가 프로그램을 설치하는 것은 이 계약 내용에 대하여 동의함을 인정하는 것입니다. <br><b>1. 사용권:</b> <br><div style='margin-left:7px;'>㈜코비젼은 사용권 증서의 내용대로 이 소프트웨어를 사용할 권리를 드립니다. 이 소프트웨어의 사용자 	수는 라이선스 구매 수량을 지칭하며 등록된 사용자 수 (Named User)를 뜻합니다. </div><b>2. 사용권의 이전: </b><div style='margin-left:7px;'>사용자가 기존제품에서 Upgrade하여 이 소프트웨어를 구입한 경우 기존제품의 사용권은 Upgrade판으로 옮겨지지만, 기존제품을 Upgrade판과 동일한 시간에 실행하지 않는다는 전제하에서 기존 제품을 사용할 수 있습니다. 따라서 기존제품의 양도, 대여 및 판매는 금지되며, Upgrade판에서 기존제품에 부속된 별도의 소프트웨어나 사용자 프로그램(utilities)의 사용권을 계속 유지 합니다. </div><b>3. 저작권: </b><div style='margin-left:7px;'>이 소프트웨어와 모든 부속물에 대한 저작권과 지적 소유권은 ㈜코비젼이 가지고 있으며, 이 권리는 대한민국의 저작권법과 국제 저작권 조약으로 보호 받습니다. 따라서 사용자는 이 소프트웨어를 사용하거나 보관용 복사본 하나를 만드는 것 이외에는 더 이상의 복사를 할 수 없습니다. 또한 ㈜코비젼의 사전 서면 동의 없이 부속된 인쇄물을 수정, 변형 및 복사할 수 없습니다.</div><b>4. 책임: </b> <div style='margin-left:7px;'>㈜코비젼을 제외한 ㈜코비젼의 제품 공급자, 대리점을 포함한 제 3자가 구두, 문서 및 기타 고지 수단을 이용하여 사용자에게 한 약속에 대해, ㈜코비젼은 책임을 지지 않습니다. </div><b>5. 기간: </b> <div style='margin-left:7px;'>본 계약은 종료될 때까지 유효하지만, 사용자가 프로그램과 그 부속물 및 보관 본을 파기하거나 계약 내용을 준수하지 않는 경우에 종료될 수 있습니다.</div><b>6. 사용자 등록 및 개정 방침: </b><div style='margin-left:7px;'>구입한 소프트웨어에 대한 고객 지원을 받거나 개정판에 대한 혜택을 얻기 위해서 개인 또는 단체 사용자는 반드시 ㈜코비젼의 SCC (Smart Care Center)에 등록 하셔야 합니다.  ㈜코비젼은 고객 등록을 마친 사용자에 한해서 고객 지원을 하며, 개정판을 할인 가격에 제공하여 드립니다. </div><b>7. 고객 지원: </b><div style='margin-left:7px;'>㈜코비젼은 고객 등록을 한 사용자에 한하여 관련 소프트웨어를 사용할 수 있는 시스템 환경에서 발생한 문제에 대한 기술적인 문의에 대하여 해결책을 제공하고자 최선을 다하며, 사용불편에 따른 신고에 대한 결과 통보에도 최선을 다합니다. </div><b>8. 인정: </b><div style='margin-left:7px;'>귀하는 이 사용계약서에 명시된 모든 내용을 읽고 이해하며, 계약 조건에 동의하고 나아가 이 내용이 옛 판의 사용계약서나 과거의 모든 주문, 약속, 광고, 고지 또는 서면 합의 사항에 우선하는 것을 인정합니다. </div><b>9. 문의: </b><div style='margin-left:7px;'>이 계약서에 대하여 의 문 사항이 있으면, ㈜코비젼에 전화, 팩스, 온라인, 서신 등을 통하여연락하여 주십시오.</div></div>"
          		  },
          		  "footer":{
          		    "CompanyCEO": "㈜코비젼 대표이사 위장복",
          		    "CompanyInfo": "㈜코비젼 (우)07794 서울시 강서구 마곡중앙8로 7길 11 (마곡동) 디앤씨캠퍼스 <br>대표 : 02-6965-3100  I FAX : 02-6965-3200 I  www.covision.co.kr"
          		  }
          		},
          		"en":{
          		  "page1":{
          		    "Subject": "Software license usage certificate",
          		    "CustomerFieldName" : "<strong>Customer</strong>",
          		    "ConTitleFieldName" : " <strong>Contract title</strong>",
          		    "SerialNumberFieldName" : "<strong>Certificate number</strong>",
          		    "DateFieldName": "<strong>Date of issue</strong>",
          		    "ProductFieldName": "<strong style='float: left;'>Product title & the number of users:&nbsp</strong>",
          		    "Content": "User or a group with the product number above has the right to facilitate the program provided by the software. <br>	Program included in the software is protected by the copyright law and the ordinances on international copyright. <br>All sorts of contents related to usage and authorization of this software is according to the contents of this agreement after purchasing the software. <br> This software usage right certificate works as a proof of purchasing the product, and should be kept in a secured place since it may be required in upgrades and other services. <br>"
          		  },
          		  "page2":{
          		     "Subject": "COVISION Corp. software license agreement",
          		     "Content": "<div  style='text-align: justify; line-height: 20px; font-size: 9pt;'>This agreement is the legal agreement on usage permission between COVISION Corp. and the user, and is not the sales agreement. Installation of the program means that the user agrees to the contents of this agreement. <br><b>1. Usage right:</b><div style='margin-left:7px;'>COVISON Corp. offers the usage right on this software, shown as the contents of the usage right certificate. The number of users under this software is the license purchase amount, which is also equivalent to the number of named users. </div><b>2. Transfer of the usage right:</b><div style='margin-left:7px;'>If the user purchases this software by upgrading the existing product, the usage right of the existing product is shifted toward the upgraded version. The existing product may be used further, unless it is run at the same time with the upgraded version. Transfer, rent and sales on the existing product is therefore prohibited. Usage right on the separate software attached to the existing product or on the user utilities, in the upgraded version, is maintained. </div>	<b>3. Copyright:</b><div style='margin-left:7px;'>All sorts of copyrights and intellectual ownerships on this software and other attachments are owned by COVISION Corp. This right is protected by the copyright law of the Republic of Korea, and the international copyright treaty.Therefore, the user cannot create a copy of this software, beside using it or making the copy for storage. Other attached printed documents cannot be revised, modified or copied unless there is an agreement in advance in writing by COVISION Corp.</div> <b>4. Responsibility:</b> <div style='margin-left:7px;'>COVISION Corp. is not responsible for all the pledges from the 3rd Party, including the product supplier and agencies of COVISION Corp. and except COVISION Corp. itself, to the users through verbally, in writing or other methods or certain notification</div><b>5. Period:</b> <div style='margin-left:7px;'>This agreement is valid till its expiration If the user damages the program, its attachments or its stored copy, or if the user does not comply with the agreement contents, the agreement may be cancelled in advance. </div><b>6. User registration & revision policy:</b><div style='margin-left:7px;'>To have the customer support on the purchased software, or to have benefit on the revised edition, an individual or a group user should be registered onto the Smart Care Center (SCC) of COVISION Corp. COVISION Corp. only provides customer support for the users after completing the customer registration, and also provides the revised edition with a discounted price.</div><b>7. Customer support:</b><div style='margin-left:7px;'>COVISION Corp. will make its best effort in providing the solution for technical requests occurred on the potential system environments that uses this software,towards the users after completing the customer registration. COVISION Corp. will also make its best effort in reporting the corresponding result from claims and complaints based on user inconvenience. </div><b>8. Recognition:</b><div style='margin-left:7px;'>Customer should note that all sorts of contents described in this usage agreement are read and clearly understood. Customer also agrees to the agreement condition, and further agrees that these contents are prioritized against the usage agreements from the older editions, and against all orders, pledges, advertisements, notifications or agreements in writing in the past. </div><b>9. Inquiry: </b><div style='margin-left:7px;'>If you have an inquiry on this agreement, please contact COVISION Corp. through telephone, fax, online, or in writing. </div></div>"
          		  },
          		  "footer":{
          		    "CompanyCEO": "COVISION Corp. CEO Wui Jang Bok",
          		    "CompanyInfo": "11, Magok Jung-ang-8-ro 7-gil, Gangseo-gu, Seoul / Zip code: 07794  <br>TEL: 02-6965-3100 / FAX: 02-6965-3200 / www.covision.co.kr"
          		  }
          		}
          };
        
        function setInitioration() {
            setBodyContext(opener.getInfo("BodyContext"));
            $("#sealImage").attr("src", opener.getUsingOfficialSeal()); 
            
            setDictionary();
            
            var sTitle;
            //document.getElementById("title").innerHTML = opener.getInfo("SUBJECT");
            try {
                //printIE();
                setTimeout(function(){
                	if(_ie) {
                		try{
                			printIE();
                		}catch(e){
                			if (e.number == -2147352573) { // e.description.indexOf("구성원이 없습니다") > -1
                				alert(Common.getDic("msg_apv_507"));
                            } else {
                                alert(e.description);
                            }
                		}
                	}
                	else {
                		window.print();
                	}
                	setInterval('window.close()', '3000');	
                 }, 300);
                var printDiv;
                printDiv = printShow;
                //   fnPrint();

            }
            catch (e) {
                // alert(e.description);
            }
        }

        function setDictionary(){
        	var langCode = $$(m_objJSON).attr("Language_Code")==undefined? "KO" : $$(m_objJSON).attr("Language_Code");
        	var dicJson;
        	
        	if(langCode.toUpperCase() == "EN"){
        		dicJson = dicContents.en;
        	}else{
        		dicJson = dicContents.ko;
        	}
        	
        	$("#mainSubject").html(dicJson.page1.Subject);
        	$("#lang_Customer").html(dicJson.page1.CustomerFieldName);
        	$("#lang_Contract").html(dicJson.page1.ConTitleFieldName);
        	$("#lang_SerialNumber").html(dicJson.page1.SerialNumberFieldName);
        	$("#lang_Date").html(dicJson.page1.DateFieldName);
        	$("#lang_Product").html(dicJson.page1.ProductFieldName);
        	$("#mainContents").html(dicJson.page1.Content);
        	$("*[name='companyCEO']").html(dicJson.footer.CompanyCEO);
        	$("*[name='companyInfo']").html(dicJson.footer.CompanyInfo);
        	$("#subSubject").html(dicJson.page2.Subject);
        	$("#subContents").html(dicJson.page2.Content);
        }
        
        function setBodyContext(sBodyContext) {
            //본문 채우기
           /*  try {
            	
                var m_objXML = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + sBodyContext);
                $(m_objXML).find("BODY_CONTEXT").children().each(function () {
                    var sCustomer, sContract, sDay, sSerialNumber;

                    if (this.tagName == "Customer_Name") { //license.html에서 id값을 가져옴
                        sCustomer = $(this).text();
                        document.getElementById("customer").innerHTML = sCustomer;
                    }
                    else if (this.tagName == "Contract_Name") {
                        sContract = $(this).text();
                        document.getElementById("contract").innerHTML = sContract;
                    }
                    else if (this.tagName == "Sdate") {
                        sDay = $(this).text();
                        document.getElementById("day").innerHTML = sDay;
                    }
                    else if (this.tagName == "SerialNumber") {
                        sSerialNumber = $(this).text();
                        document.getElementById("SerialNumber").innerHTML = sSerialNumber;
                    }

                });
                if (typeof opener.formJson.BODY_CONTEXT.sub_table1 != 'undefined') {
                  //  XFORM.multirow.load(JSON.stringify(opener.formJson.BODY_CONTEXT.sub_table1), 'json', '#sub_table1', 'R');
                    addLine2(opener.formJson.BODY_CONTEXT.sub_table1);
                }
                //EASY.init();
            }
            catch (e) { } */
            
            try {
            	m_objJSON= $.parseJSON(sBodyContext);
            
            	for(var key in m_objJSON){
                    var sCustomer, sContract, sDay, sSerialNumber;

                    if (key == "Customer_Name") { //license.html에서 id값을 가져옴
                        sCustomer = $$(m_objJSON).attr(key);
                        document.getElementById("customer").innerHTML = sCustomer;
                    }
                    else if (key == "Contract_Name") {
                        sContract = $$(m_objJSON).attr(key);
                        document.getElementById("contract").innerHTML = sContract;
                    }
                    else if (key == "Sdate") {
                        sDay = $$(m_objJSON).attr(key);
                        document.getElementById("day").innerHTML = sDay;
                    }
                    else if (key == "SerialNumber") {
                        sSerialNumber = $$(m_objJSON).attr(key);
                        document.getElementById("SerialNumber").innerHTML = sSerialNumber;
                    }
            	}
                 
                if (typeof opener.formJson.BodyContext.SubTable1 != 'undefined') {
                  //  XFORM.multirow.load(JSON.stringify(opener.formJson.BODY_CONTEXT.sub_table1), 'json', '#sub_table1', 'R');
                    addLine2(opener.formJson.BodyContext.SubTable1);
                }
                //EASY.init();
            }
            catch (e) { }
        }

        function printIE() {
            var wb = '<OBJECT ID="WebBrowser" WIDTH=0 HEIGHT=0 CLASSID="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>';
            document.body.insertAdjacentHTML('beforeEnd', wb);
            WebBrowser.ExecWB(7, -1);
            WebBrowser.outerHTML = '';
            self.close();
        }

        function addLine2(tbID) { //멀티로우
            var tableIndex;
            var oNewRow;

            if (tbID.length == undefined) {
                tableIndex = document.getElementById("SubTable1");
                oNewRow = tableIndex.insertRow(tableIndex.rows.length - 1);

                var oNewCell1 = oNewRow.insertCell(0);

                oNewCell1.style.fontWeight = "bold";
                oNewCell1.style.fontSize = "11pt";
                oNewCell1.style.lineHeight = "160%";

                if (tbID.Note == null || tbID.Note=="") {
                    oNewCell1.innerHTML = tbID.Product_Name + "&nbsp;" + tbID.Amount + "&nbsp;" + tbID.Unit;
                }
                else {
                    oNewCell1.innerHTML = tbID.Product_Name + "&nbsp;" + tbID.Amount + "&nbsp;" + tbID.Unit + "&nbsp;" + "(" + tbID.Note + ")";
                }
            }

            else{
                tb = document.getElementById("SubTable1");
                for (var i = 0; i < tbID.length; i++) {
                    oNewRow = tb.insertRow(tb.rows.length - 1);
                        var oNewCell1 = oNewRow.insertCell(0);
                        oNewCell1.style.fontWeight = "bold";
                        oNewCell1.style.fontSize = "11pt";
                        oNewCell1.style.lineHeight = "140%";

                        if (tbID[i].Note == null || tbID[i].Note == "" || tbID[i].Note == undefined ) {
                            oNewCell1.innerHTML = tbID[i].Product_Name + "&nbsp;" + tbID[i].Amount + "&nbsp;" + tbID[i].Unit;
                        }

                        else {
                            oNewCell1.innerHTML = tbID[i].Product_Name + "&nbsp;" + tbID[i].Amount + "&nbsp;" + tbID[i].Unit + "&nbsp;" + "(" + tbID[i].Note + ")";
                        }
                        
                    }
               }
            }
    </script>

