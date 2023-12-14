<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
   table td {
   	line-height: normal;
   }
   
  * {
   		 font-size:13px;
   		 line-height:18px;
	}
</style>


<!-- 발주서 인쇄 양식   -->
<body>
    <script type="text/javascript" language="javascript" src="printForm.js<%=resourceVersion%>"></script>
    <div id='printShow' style="padding: 10px">
          <table class="table_OFFICAL_DOCUMENT" border="0" bordercolor="#111111" cellpadding="0" cellspacing="0" style="BORDER-COLLAPSE: collapse; width:99%; margin-top:3px;" align="center" ID="Table6">
						<tr id="logoTB" ><!--style="display:none;"-->
							<td>
								 <table cellpadding="0" cellspacing="0" style="border-collapse: collapse;" align="left" width="100%" height="42" >
									<tr>
				                        
			                            <td colspan="4"  style="font-size: 24pt; padding-top:5px; font-family: 바탕체; text-align:center;">
					                        발&nbsp;주&nbsp;서
				                        </td>
                                        
                                    </tr>
			                        <tr >
                                        <td colspan="4" style="text-align:right;width:40%;"><img  alt="logo" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/logo_covision.png" align="right" style="width: 154px; " /></td>
				                        
                                       
			                        </tr>
			                        <tr >
				                        <td colspan="2" style="width:20%;">
                                        <table  cellpadding="0" cellspacing="0">
					                        <tr>
                                            <td style="padding-bottom:8px;"><strong>발&nbsp;&nbsp;&nbsp;주&nbsp;&nbsp;&nbsp;일&nbsp;:</strong>&nbsp;<span id="OrderDate" ></span></td>
                                            </tr>
                                            <tr>
                                            <td style="padding-bottom:8px;"><strong>발&nbsp;주&nbsp;번&nbsp;호&nbsp;:</strong>&nbsp;<span id="OrderNum"></span></td>
                                            </tr>
                                            <tr>
                                            <td style="padding-bottom:8px;"><strong>수&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;신&nbsp;:</strong>&nbsp;<span id="businessName"></span></td>
                                            </tr>
                                            <tr>
                                            <td><strong>참&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;조&nbsp;:</strong>&nbsp;<span id="name_1"></span>&nbsp;&nbsp;(<span id="number_1"></span>)</td>
                                            </tr>
                                            </table>
				                        </td>
                                        <td colspan="2" style="padding-top:20px;width:50%;">
                                        <table style="width:97%; border: 1px solid #d5d5d5; border-collapse:collapse;" cellpadding="15px" cellspacing="0" cellpadding="10px">
                                        	<colgroup>
                                        		<col style="width:85px;"/>
                                        		<col/>
                                        	</colgroup>
                                            <tr style="border: 1px solid #d5d5d5;">
                                            	<td style="border: 1px solid #d5d5d5; padding:6px;" >사업자 번호</td>
                                            	<td style="padding:6px;">109-81-73212</td>
                                            </tr>
                                            <tr>
                                           		 <td style="border: 1px solid #d5d5d5; padding:6px;">회&nbsp;&nbsp;사&nbsp;&nbsp;명</td>
                                           		 <td style="padding:6px;">주식회사 코비젼</td>
                                            </tr>
                                            <tr  style="border: 1px solid #d5d5d5;">
                                          		  <td style="border: 1px solid #d5d5d5; padding:6px;">대&nbsp;&nbsp;표&nbsp;&nbsp;자</td>
                                            	  <td style="padding:6px;">대표이사&nbsp;&nbsp;위&nbsp;장&nbsp;복&nbsp;&nbsp;(인)<img id="imgSeal"  style="position: absolute; top: 150px; right: 130px; width: 60px; height: 60px;" /></td>
                                            </tr>
                                            <tr style="border: 1px solid #d5d5d5;">
                                            	<td style="border: 1px solid #d5d5d5; padding:6px;">주&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;소</td>
                                           		<td  style="padding:6px;">서울시 강서구 마곡중앙8로 7길 11(마곡동) <br>D&C CAMPUS</td>
                                            </tr>
                                            </table>
                                        </td>
                                        
			                        </tr>
                                    <tr height="22" >
				                        
                                        <td colspan="4">
                                            하기와 같이 발주 합니다.
                                        </td>
			                        </tr>
                                    <tr>
                                        <td style="height:18px;">
                                        </td>
			                        </tr>
                                    <tr >
                                        <td colspan="4" style="padding-bottom: 5px;font-size:14px; margin-bottom:3px;" >
                                            <strong>1. 발&nbsp;주&nbsp;명&nbsp;세</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4" style="padding-left:20px;" >
                                            <table  cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="padding-bottom:3px;">1-1. 프로젝트명 : </td>
                                                <td style="padding-bottom:3px;"><span id="projectName"></span></td>
                                            </tr>
                                            <tr>
                                                <td style="padding-bottom:3px;">1-2. 발주금액 : </td>
                                                <td style="padding-bottom:3px;"><span id="orderTotal2"></span>&nbsp;&nbsp;&nbsp;&nbsp;<span id="hangeul"></span>&nbsp;&nbsp;(VAT 별도)</td>
                                            </tr>
											<tr>
                                                <td style="padding-bottom:3px;">1-3. 계약기간 : </td>
                                                <td style="padding-bottom:3px;"><span id="CONTRACT_SDT"></span> ~ <span id="CONTRACT_EDT"></span></td>
                                            </tr>
                                            <tr>
                                                <td style="padding-bottom:3px;">1-4. 발주내역 : </td>
                                                <td style="padding-bottom:3px;"><span id=""></span></td>
                                            </tr>
                                            </table>
                                        </td>
			                        </tr>
								</table>
							</td>
						</tr>

						<tr>
			                <td style="height:5px;padding:0px;">
                                <table class="table_13"   cellpadding="0" cellspacing="0" style="font-size:11px;">
								<colgroup>
									<col style="width: 120px;">
									<col style="width: *">
									<col style="width: 110px;">
									<col style="width: 105px;">
									<col style="width: 130px;">
								</colgroup>
								<tr >
							        <td style="font-size:13px;font-family:맑은고딕; text-align:center"><strong>구분</strong></td>
                                    <td style="font-size:13px;font-family:맑은고딕;text-align:center"><strong>품목</strong></td>
                                    <td style="font-size:13px;font-family:맑은고딕;text-align:center"><strong>공급단가</strong></td>
                                    <td style="font-size:13px;font-family:맑은고딕;text-align:center"><strong>수량/공수</strong></td>
                                    <td style="font-size:13px;font-family:맑은고딕;text-align:center"><strong>금액</strong></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_1_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_1"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_1"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_1"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_1"></span></td>
						        </tr>
						        <tr >
							        <td style="height:25px;"><span id="division_2_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_2"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_2"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_2"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_2"></span></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_3_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_3"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_3"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_3"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_3"></span></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_4_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_4"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_4"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_4"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_4"></span></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_5_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_5"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_5"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_5"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_5"></span></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_6_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_6"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_6"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_6"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_6"></span></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_7_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_7"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_7"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_7"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_7"></span></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_8_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_8"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_8"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_8"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_8"></span></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_9_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_9"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_9"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_9"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_9"></span></td>
						        </tr>
                                <tr >
							        <td style="height:25px;"><span id="division_10_TEXT"></span></td>
                                    <td style="height:25px;"><span id="item_10"></span></td>
                                    <td style="height:25px;text-align:right"><span id="unitCost_10"></span></td>
                                    <td style="height:25px;text-align:right"><span id="amount_10"></span></td>
                                    <td style="height:25px;text-align:right"><span id="sum_10"></span></td>
						        </tr>
                                <tr >
							        <td colspan="4" style="font-size:13px;font-family:맑은고딕; text-align:center;"><strong>합&nbsp;계&nbsp;금&nbsp;액</strong></td>
                                    <td style="text-align:right;"><span id="total"></span></td>
						        </tr>
                                <tr >
							        <td colspan="4" style="background-color:#d0d0d0; font-size:13px;font-family:맑은고딕; text-align:center"><strong>최&nbsp;종&nbsp;발&nbsp;주&nbsp;금&nbsp;액&nbsp;&nbsp;&nbsp;(VAT 별도)</strong></td>
                                    <td style="background-color:#d0d0d0;text-align:right; font-weight: bold;"><span id="orderTotal1"></span></td>
						        </tr>
                                </table>
			                </td>
		                </tr>
						
					</table>
                    <table  cellpadding="0" cellspacing="0" style="margin-top:15px;">
                        <tr>
                            <td>
                            <strong>2.발 주 조 건</strong><br />
                            <div style="padding-left: 12px;">2-1. 납기일 : 협의에 따름</div>
                            <div>
                                <table>
                                    <tr>
                                        <td style="min-width:90px; padding-left: 10px;" valign="top">2-2. 지불조건 :</td>
                                        <td style="padding-top: 2px;"><span id="radio1"></span><span id="etc"></span>
                                            <br />
                                            (본 대금지급조건은 유첨의 견적서상의 대금지급 조건보다 우선한다.)<br />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <strong>3. 특기사항</strong><br />
                            <div>
                                <table>
                                    <tr>
                                        <td style="padding-left: 10px;" valign="top">3-1.</td>
                                        <td valign="top">&nbsp;-&nbsp;</td>
                                        <td> H/W의 경우 1년간의 유지보수, 기술지원 및 업그레이드 비용을 포함하여, 사용자 교육 및 공급물품 안정화에 적극 협력한다.</td>
                                    </tr>
                                    <tr>
                                    	<td style="padding-left: 10px;" valign="top">3-2. </td>
                                    	<td colspan="2">(지체상금)</td>
                                    </tr>
                                    <tr>
                                    	<td style="padding-left: 10px;" valign="top"></td>
                                    	<td valign="top">&nbsp;-&nbsp;</td>
                                    	<td>"을"이 계약기간 내에 용역수행 (물품 납품)을 완료하지 못한 경우, "을"은 그 지체일수에 총계약금의 1,000분의 2.5 (물품의 경우 3) 를 곱한 금액 )이하 "지체상금" 이라 한다)을 "갑"에게 배상하여야 하며, 지체상금의 범위는 계약금액의 20%를 넘을 수 없다.</td>
                                    </tr>
                                    <tr>
                                    	<td style="padding-left: 10px;" valign="top">3-3. </td>
                                    	<td valign="top">&nbsp;-&nbsp;</td>
                                    	<td>"을"은 상기의 발주/계약에 의 해 개발된 개발 완료 성과물 또는 납품물에 대하여 그 기능 및 성능을 보장하여야 하며 그에 대한 "갑"의 검수완료 후 1년간 성과물 또는 납품물의 성능 등에 대한 하자보증 책임을 부담하여야하며, 이에 대한 보증 증권을 제공하여야 한다.</td>
                                    </tr>
                                </table>
                            </div>
                            <strong style="padding-top: 8px; display: block;">4. 첨부 : 견적서</strong></td>
                        </tr>
                    </table>

    </div>
	<div id="loading" style="text-align:center;z-index:10;background-color:red;margin:0 auto;position:absolute; top:50%; left:50%; height:20px; margin-left:-10px; margin-top:-10px;display:none ">
        <img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/loading12.gif" style="text-align:center;" />
    </div>
	<script type="text/javascript" language="javascript">
	    var bSelected = false;

	    window.onload = function () {
	        document.getElementById("OrderNum").innerHTML = top.opener.getInfo("FormInstanceInfo.DocNo");
	        $("#imgSeal").attr("src",top.opener.getUsingOfficialSeal());

	        var m_evalJSON = $.parseJSON(top.opener.document.getElementById("APVLIST").value);
	        var taskInfo = $$(m_evalJSON).find("steps > division > step > ou > person > taskinfo[status='completed']");
	        var LastDate = taskInfo.concat().eq(taskInfo.valLength()-1).attr("datecompleted");
	        
	        if(LastDate > Common.getBaseConfig("BaseTimeZone_ApvLine")) {
	        	LastDate = XFN_TransDateServerFormat(CFN_TransLocalTime(LastDate)).substring(0, 10);
	        } else {
	        	LastDate = XFN_TransDateServerFormat(LastDate).substring(0, 10);
	        }
	        
	        document.getElementById("OrderDate").innerHTML = LastDate;
	        setBodyContext(top.opener.getInfo("BodyContext"));

	        try {
	            printDiv = printShow;
	            // $("#printShow").append(printDiv);
//	            if (window.ActiveXObject !== undefined) {
//	                printGo();
//	            } else {
	                window.print();
	                //window.close();

//	            }
	        }
	        catch (e) {
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
	        //본문 채우기
	        //alert("2");
	    	
	    	try{
	    		var m_objJSON= $.parseJSON(sBodyContext);
	    		
	    		for(var key in m_objJSON){
	    			if(key=="orderTotal"){
	    				document.getElementById("orderTotal1").innerHTML = $$(m_objJSON).attr(key);
	                    document.getElementById("orderTotal2").innerHTML = $$(m_objJSON).attr(key);
	    			}else if(key=="RDO_condition_TEXT"){
	    				document.getElementById("radio1").innerHTML = $$(m_objJSON).attr(key);
	    			}else if (key.indexOf("division_") != -1) {
	                	if($$(m_objJSON).attr(key) == "구분")
	                		innerHtmlData(key, "");
	                	else
	                		innerHtmlData(key,$$(m_objJSON).attr(key));
	                }else if (key.indexOf("unitCost_") != -1 || key.indexOf("amount_") != -1 || key.indexOf("sum_") != -1) {
	                	innerHtmlData(key, CnvtComma($$(m_objJSON).attr(key).replace(/\,/g, "")));
	                }else {
	                	innerHtmlData(key, $$(m_objJSON).attr(key));
	                }
	    		}
	    		
	    	}
	    	catch(e){};
	        /* try {
	            var m_objXML = $.parseXML(BodyContext);
	            $(m_objXML).find("BODY_CONTEXT").children().each(function () {
	                if (this.tagName == "orderTotal") {
	                    document.getElementById("orderTotal1").innerHTML = $(this).text();
	                    document.getElementById("orderTotal2").innerHTML = $(this).text();
	                }
	                else if (this.tagName == "RDO_condition_TEXT") {
	                	document.getElementById("radio1").innerHTML = $(this).text();
	                }
	                else if (this.tagName.indexOf("division_") != -1) {
	                	if($(this).text() == "구분")
	                		innerHtmlData(this.tagName, "");
	                	else
	                		innerHtmlData(this.tagName, $(this).text());
	                }
	                else if (this.tagName.indexOf("unitCost_") != -1 || this.tagName.indexOf("amount_") != -1 || this.tagName.indexOf("sum_") != -1) {
	                	innerHtmlData(this.tagName, CnvtComma($(this).text()));
	                }
	                else {
	                	innerHtmlData(this.tagName, $(this).text());
	                }
	            });
	        }
	        catch (e) { } */
	        
	    }

	    /*** 데이터 뿌려주기 - Value ***/
	    function innerHtmlData(nodeNm, nodeVal) {
	        var dom;
	        if (top.opener.getInfo("Request.templatemode") == "Write") {
	            if (document.getElementsByName(nodeNm)[0] != undefined) {
	                if (nodeNm.indexOf("FORM_ATTACH") != -1) {
	                    setForm_Attach(nodeVal);
	                    document.getElementsByName(nodeNm)[0].value = nodeVal;
	                } else if (nodeNm.indexOf("OPT") != -1 || nodeNm.indexOf("RDO") != -1 || nodeNm.indexOf("RDV") != -1) {
	                    setRadio(nodeNm, nodeVal);
	                } else if (nodeNm.indexOf("CHK") != -1) {
	                    setChk(nodeNm, nodeVal);
	                } else if (nodeNm.indexOf("tbContentElement") != -1) {
	                    switch (Common.getBaseConfig('EditorType')) {
	                        case "0":
	                            document.getElementById("txtareaBody").value = nodeVal;
	                            break;
	                        case "1": break;
	                        case "2":
	                            dom = document.tbContentElement.getDom();
	                            dom.body.innerHTML = nodeVal.replace(/<br \/>/gi, "");
	                            break;
	                        case "3":
	                            tbContentElement.SetHtmlValue(nodeVal);
	                            break;
	                        case "4":
	                            if (_ie) {
	                                dom = document.tbContentElement.getDom();
	                                dom.body.innerHTML = nodeVal.replace(/<br \/>/gi, "");
	                            } else { tbContentElement.SetHtmlValue(nodeVal); }
	                            break;
	                        case "5":
	                            document.tbContentElement.value = nodeVal;
	                            break;
	                    }
	                } else {
	                    document.getElementsByName(nodeNm)[0].value = nodeVal;
	                }
	            } else {
	                if (nodeNm.indexOf("tbContentElement") != -1) {
	                    switch (Common.getBaseConfig('EditorType')) {
	                        case "0":
	                            document.getElementById("txtareaBody").value = nodeVal;
	                            break;
	                        case "1":
	                            break;
	                        case "2":
	                            dom = document.tbContentElement.getDom();
	                            dom.body.innerHTML = nodeVal.replace(/<br \/>/gi, "");
	                            break;
	                        case "3":
	                            tbContentElement.SetHtmlValue(nodeVal);
	                            break;
	                        case "4":
	                            if (_ie) {
	                                dom = document.tbContentElement.getDom();
	                                dom.body.innerHTML = nodeVal.replace(/<br \/>/gi, "");
	                            } else { tbContentElement.SetHtmlValue(nodeVal); }
	                            break;
	                        case "5": document.tbContentElement.value = nodeVal;
	                            break;
	                    }
	                }
	            }
	        } else {
	            if (document.getElementById(nodeNm) != undefined) {
	                if (nodeNm.indexOf("OPT") != -1) {
	                    setRadio(nodeNm, nodeVal);
	                } else if (nodeNm.indexOf("RDO") != -1) {
	                    setRadioRead(nodeNm, nodeVal);
	                } else if (nodeNm.indexOf("FORM_ATTACH") != -1) {
	                    setForm_Attach(nodeVal);
	                } else if (nodeNm.indexOf("tbContentElement") != -1) {
	                    $("#tbContentElement").html(nodeVal); //.replace(/\n/gi, "<br \/>")
	                } else if (nodeNm.indexOf("CHK") != -1) {
	                    setChkRead(nodeNm, nodeVal);
	                } else {
	                    try {
	                        document.getElementById(nodeNm).innerHTML = nodeVal.replace(/\n/gi, "<br \/>");
	                    } catch (e) {
	                        document.getElementById(nodeNm).value = nodeVal;
	                    }
	                }
	            } else if (nodeNm.indexOf("RDV") != -1) {
	                setRadioValueRead(nodeNm, nodeVal);
	            }
	        }
	    }

	    var g_Win;
	    //일반window.open
	   
/************************************************************************
함수명		: CnvtComma
작성목적	: 빠져나갈때 포맷주기(123456 => 123,456)
*************************************************************************/
	    function CnvtComma(num) {
	    	try {
	    		var ns = num.toString();
	    		var dp;

	    		if (isNaN(ns) || ns == "0")
	    			return "";

	    		dp = ns.search(/\./);

	    		if (dp < 0) dp = ns.length;

	    		dp -= 3;

	    		while (dp > 0) {
	    			ns = ns.substr(0, dp) + "," + ns.substr(dp);
	    			dp -= 3;
	    		}
	    		return ns;
	    	}
	    	catch (ex) {
	    	}
	    }
	</script>
</body>
</html>


