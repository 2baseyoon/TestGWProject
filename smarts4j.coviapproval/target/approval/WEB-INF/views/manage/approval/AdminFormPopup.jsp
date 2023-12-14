<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<% String strForm_id 	= request.getParameter("FormID");%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<c:set var="strForm_id" value="<%=strForm_id%>"/>
<c:set var="strisSaaS" value="${isSaaS}"/>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	.lineHeight2{
		line-height:2.2;
	}
	.verticalMiddle{
		vertical-align: middle;
		line-height:1;
	}
	#divSubTableSetting .t_2 {
		margin-top: 0px !important;
	}
	.ml10 {
		margin-left: 10px;
	}
	.AXFormTable[name*="FieldTable"]{
	    width:99%;
	}
	
	.AXFormTable[name*="FieldTable"] th.table_top_first{
	    width:20px;
	}
	.chkeckSubTableOn {
		display:inlini-bolck; padding-left:20px;background:url(<%=cssPath%>/covicore/resources/images/theme/icn_png.png) no-repeat -478px -522px;
	}
	.chkeckSubTableOff {
		display:inlini-bolck; padding-left:20px; background:url(<%=cssPath%>/covicore/resources/images/theme/icn_png.png) no-repeat -478px -569px;
	}
	.t_2 {
		margin-top:10px !important; margin-bottom:5px; font-size:13px; background:url(<%=cssPath%>/covicore/resources/images/theme/icn_png.png) no-repeat -460px -405px; padding-left:24px; color:#333333; line-height:25px; font-weight:bold;
	}
	.help_ico.active::after {
	    display: none;
	}
</style>
<form name="form1">
	<div id="popBox" style="display:none;">
       	<div class="sadmin_pop">
			<ul class="tabMenu clearFloat">
				<li class="active"><a onclick="clickTab(this);" value="divFormBasicInfo"><spring:message code='Cache.lbl_FormBasicInfo'/></a></li><!--양식기본정보-->
				<li><a onclick="clickTab(this);" value="divFormHtmlnfo"><spring:message code='Cache.lbl_FormHtmlInfo'/></a></li><!--양식본문정보-->
				<li><a onclick="clickTab(this);" value="divOptionalSetting"><spring:message code='Cache.lbl_OptionInfo'/></a></li><!--부가정보-->
				<li><a onclick="clickTab(this);" value="divSubTableSetting" <covi:admin hiddenWhenEasyAdmin="true" />><spring:message code='Cache.lbl_SubTableSetting'/></a></li>
				<li><a onclick="clickTab(this);" value="divAttributeInfo"><spring:message code='Cache.lbl_attributeinfo'/></a></li><!--양식별특성-->
				<li><a onclick="clickTab(this);" value="divAutoApprovalLine"><spring:message code='Cache.lbl_apv_AutoApproval'/></a></li>		
			</ul>
			 <!--양식기본정보 탭 시작 -->	 
			<div id="divFormBasicInfo" class="tabContent active">				
			    <table class="sadmin_table sa_menuBasicSetting mb20">
			      <colgroup>
						<col width="200px;">
						<col width="298px;">
						<col width="*">
					</colgroup>
			      <tbody>
			        <tr <covi:admin hiddenWhenEasyAdmin="true" />>
			          <th><spring:message code='Cache.lbl_apv_formcreate_LCODE02'/></th>  <!--양식키(영문)-->
			          <td>
		                  <input name="fmpf" id="fmpf" type="text" class="menuName04" maxlength="30"/>
		                  <span style="margin-left:15px;color:white;cursor:hand;" onclick="javascript:setTest();">_</span></td>
			          <th rowspan="2"><spring:message code='Cache.msg_apv_formcreate_prefix'/></th>
			        </tr>
			        <tr <covi:admin hiddenWhenEasyAdmin="true" />>
			          <th><spring:message code='Cache.lbl_apv_formcreate_LCODE06'/></th>  <!--버젼-->
			          <td class="br"><input name="fmrv" id="fmrv" type="text" class="menuName04" maxlength="2" onkeyup="MakeFormFileNm();" onkeypress="CheckInteger();" /></td>
			        </tr>
			        <tr>
			          <th><spring:message code='Cache.lbl_apv_formcreate_LCODE03'/></th>  <!--양식명-->
			          <td style="padding:0px" id="dic">	</td>
			          <!-- <td><input name="fmnm" id="fmnm" type="text" class="AXInput" maxlength="50" style="width:250px;"></td> -->
			          <th><spring:message code='Cache.msg_apv_formcreate_name'/></th>
			        </tr>
		
			        <tr>
			          <th><spring:message code='Cache.lbl_FormCate'/></th>  <!--양식분류-->
			          <td>
			          	<select id="selclass" name="selclass" class="menuName04 mr0"></select></td>				          
			          <th id="th_Desc_selclass" rowspan="2"><spring:message code='Cache.msg_apv_formcreate_categories'/></th>
			        </tr>
			        <tr id="tr_fmsk" <covi:admin hiddenWhenEasyAdmin="true" />>
			          <th><spring:message code='Cache.lbl_apv_formcreate_LCODE07'/></th>  <!--정렬-->
			          <td class="br"><input name="fmsk" id="fmsk" type="text" class="menuName04" onkeypress="CheckInteger();" maxlength="15" /></td>
			        </tr>
			        <tr>
			          <th><spring:message code='Cache.lbl_apv_formcreate_LCODE04'/></th>  <!--양식 프로세스-->
			          <td>
			          	<select id="selschema" name="selschema" class="menuName04 mr0"></select>
		                <a href="#" onclick="openSchema()" class="btnTypeDefault"><spring:message code='Cache.btn_Setting'/></a>
			          </td>
			          <th><spring:message code='Cache.msg_apv_formcreate_schema'/></th>
			        </tr>
		              <tr style="display:none;">
			          <td colspan="2" id="td_selechema_desc"></td>
			        </tr>
			        <tr>
			          <th><spring:message code='Cache.lbl_apv_formcreate_LCODE12'/></th>  <!--사용여부-->
			          <td colspan="2">
			          	<select name="fmst" id="fmst"  class="w200p">
			          	<option value="Y"><spring:message code='Cache.lbl_apv_formcreate_LCODE13'/></option>
			          	<option value="N"><spring:message code='Cache.lbl_apv_formcreate_LCODE14'/></option>
			          	</select>
			          </td>
			        </tr>
			        <tr>
			          <th><spring:message code='Cache.lbl_apv_formcreate_LCODE16'/></th>  <!--설명-->
			          <td colspan="2"><textarea name="fmds" id="fmds" rows="10" cols="30" maxlength="256"></textarea></td>
			        </tr>
			        <tr id="trCompanyCode" <covi:admin hiddenWhenEasyAdmin="true" />>
			          <th><spring:message code='Cache.lbl_OwnedCompany'/></th> <!--소유회사-->
			          <td colspan="2">
			          	<select name="selectCompanyCode" id="selectCompanyCode"  class="w200p" onChange="ChangeEntCode()"></select>
			          </td>
			        </tr>
			        <tr>
			          <th><spring:message code='Cache.lbl_SettingPermission'/></th> <!--권한설정-->
			          <td colspan="2" style="padding:0px;">
						<table class="sadmin_inside_table">
							<tr>
						          <td>
						          	<div class="radioStyle05">
						          		<input type="radio" id="AclAllYN_Y" name="AclAllYN" value="Y" onchange="changeAclAllYn()" />
						          		<label for="AclAllYN_Y"><spring:message code='Cache.btn_All'/></label>
						          	</div>
						          	<div class="radioStyle05">
						          		<input type="radio" id="AclAllYN_N" name="AclAllYN" value="N" onchange="changeAclAllYn()" />
						          		<label for="AclAllYN_N"><spring:message code='Cache.lbl_SettingPermission'/></label>
						          	</div>
						          	<span id="permissionBtnSpan" style="visibility:hidden;">
						          		<a href="#" class="btnTypeDefault" onclick="OrgMap_Open(0);"><spring:message code='Cache.lbl_SettingPermission'/></a>
						          	</span>
						          </td>
							</tr>
						</table>
					  </td>
			        </tr>
			        <tr>
						<th>
							<spring:message code='Cache.lbl_FormIcon'/><!-- 양식아이콘 -->
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="btn_FormIcon"/>
							</div>
						</th>
						<td colspan="2">
							<div class="form_icon_selector"/>
						</td>
					</tr>
			        <!-- <tr>
			          <td>프로세스메뉴얼URL</td>  프로세서메뉴얼 URL 
			          <td colspan="2"><input name="ProcessManual" id="ProcessManual" type="text" style="float:left; width:80%;" maxlength="256" /></td>
			        </tr> -->			                   
			      </tbody>
			    </table>			      		       
	        </div>		   
	        <!--양식기본정보 탭 종료 -->
	        
	        <!--양식본문정보 탭 시작 -->
			<div id="divFormHtmlnfo"  class="tabContent">		
	          <table class="sadmin_table sa_menuBasicSetting mb20" cellpadding="0" cellspacing="0">
		          <colgroup>
			        <col width="200px;">
			        <col width="*">
		          </colgroup>
		          <tbody>
		            <tr <covi:admin hiddenWhenEasyAdmin="true" />>
		              <th><spring:message code='Cache.lbl_FormFileNm'/></th> <!--HTM양식파일명-->
                      <td style="padding:0px;">
                        <table width="100%" class="sadmin_inside_table">
                            <tr id="trFormCreateKind">
                                <td>
                                	<div class="radioStyle05"><input type="radio" id="rdoNewCreate" name="rdoFormCreateKind" onclick="ChangeFormCreateKind(1);" checked="true"><label for="rdoNewCreate"><spring:message code='Cache.lbl_NewCreate'/></label></div>
                                	<div class="radioStyle05"><input type="radio" id="rdoOldFileUse" name="rdoFormCreateKind" onclick="ChangeFormCreateKind(2);" /><label for="rdoOldFileUse"><spring:message code='Cache.lbl_UseOldFile'/></label></div>
                                    <input type="hidden" name="FormCreateKind" id="FormCreateKind" value="1" />
                                </td>
                            </tr>
                            <tr>
                                <td style="padding:0px;">
                                    <div id="divNewCreate">
                                        <table class="sadmin_inside_table">
                                        	<colgroup>
												<col width="110px;">
												<col width="298px;">
												<col width="*">
											</colgroup>
											
											<tr>
                                                <th><spring:message code='Cache.lbl_OrginFile'/></th> <!--원본파일-->
                                            <td>
                                            	<input type="text" id="sourcefile" name="sourcefile" class="menuName04 mr0" readonly="readonly"/>
                                            	<a href="#" class="btnTypeDefault" onclick="SelectOrginFile(1); return false;"><spring:message code='Cache.lbl_selection'/></a></td>
                                            <th><spring:message code='Cache.lbl_apv_SelCopyingFile'/></th><!--원본파일이 있는 경우 선택하세요-->
                                            </tr>
                                            <tr>
                                               <th><spring:message code='Cache.lbl_apv_FileName'/></th> <!--파일명-->
                                               <td><input type="text" id="flnm" name="flnm" class="menuName04" readonly="readonly" /></td>
                                               <th><spring:message code='Cache.lbl_ApprovalComm1'/></th> <!--신규로만들 html파일명이며 이는 양식키와 버젼의 조합으로 만들어집니다-->
                                            </tr>
                                        </table>
                                          </div>	  
                                        <div id="divOldFileUse" style="display:none;">
                                       	<table class="sadmin_inside_table">
                                       		<colgroup>
												<col width="110px;">
												<col width="298px;">
												<col width="*">
											</colgroup>
                                            <tr>
                                            	<th>
                                            	<c:choose><c:when test="${empty strForm_id}"><spring:message code='Cache.lbl_UsingFile'/></c:when>	                
                                            	<c:otherwise><spring:message code='Cache.lbl_apv_FileName'/></c:otherwise></c:choose>&nbsp;
                                            	</th> <!--이용할 파일-->	                                                
                                                <td>
                                                    <input type="text" id="UsingExistFile" name="UsingExistFile" class="menuName04 mr0" readonly="readonly"/>
                                                    <input type="hidden" id="tpnm" name="tpnm" /> <!--템플릿파일명(현재템플릿기능사용하지않음)-->
                                                    <a href="#" class="btnTypeDefault" onclick="SelectOrginFile(2); return false;"><spring:message code='Cache.lbl_selection'/></a> <!--선택-->
                                                </td>
                                                <th>*<spring:message code='Cache.lbl_SelUsingExistFile'/></th> <!--이용할 기존파일을 선택하세요-->
                                            </tr>
                                        </table>
                                    </div>                          
                                </td>
                            </tr>	                            
                        </table>
                      </td>				          
		            </tr>	
		            <!-- [20-06-05] 통합양식 사용하지 않는 경우 read 페이지 개발 고려되면 display 로 변경할 것
		                 			현재는 무조건 통합양식으로 개발하도록 표시하지 않음.  -->
			        <tr style="display: none;" <covi:admin hiddenWhenEasyAdmin="true" />>
		              <th><spring:message code='Cache.msg_apv_formcreate_t_tit01'/></th>
			          <td>
                        <span class="chkStyle01">
                        	<input type="checkbox" id="UnifiedFormYN" name="UnifiedFormYN" value="Y" checked="checked">
                        	<label for="UnifiedFormYN"><span></span><spring:message code='Cache.lbl_Use'/><spring:message code='Cache.msg_apv_formcreate_writeselect'/></label>
                        </span>
                      </td>
		            </tr>		
			        <tr id="trMobileFormYN" style="display: none;" <covi:admin hiddenWhenEasyAdmin="true" />>
		              <th><spring:message code='Cache.lbl_apv_isMobileForm'/></th> <!-- 모바일 양식 -->
			          <td>
                        <span class="chkStyle01">
                        	<input type="checkbox" id="MobileFormYN" name="MobileFormYN" value="Y" onchange="DisableSpecificOpt(this);">
                        	<label for="MobileFormYN"><span></span><spring:message code='Cache.lbl_Use'/></label>
                        </span>
                      </td>
		            </tr>
		            <tr id="trUseMultiEditYN" style="display: none;" <covi:admin hiddenWhenEasyAdmin="true" />>
		              <th><spring:message code='Cache.lbl_apv_isMultiDraft'/></th> <!-- 다안기안 설정 -->
			          <td>
                        <span class="chkStyle01">
                        	<input type="checkbox" id="UseMultiEditYN" name="UseMultiEditYN" value="Y" onchange="DisableSpecificOpt(this);">
                        	<label for="UseMultiEditYN"><span></span><spring:message code='Cache.lbl_Use'/></label>
                        </span>
                      </td>
		            </tr>
                    <tr <covi:admin hiddenWhenEasyAdmin="true" />>
		              <th><spring:message code='Cache.lbl_apv_hwpEditor'/></th> <!-- HWP 에디터 -->
			          <td>
                        <span class="chkStyle01">
                        	<input type="checkbox" id="UseHWPEditYN" name="UseHWPEditYN" value="Y" class="input_check" onchange="ViewOrHideUseEditYN(this);">
                        	<label for="UseHWPEditYN"><span></span><spring:message code='Cache.lbl_Use'/></label>
                        </span>
                      </td>
		            </tr>   
                    <tr style="display: none;" <covi:admin hiddenWhenEasyAdmin="true" />>
		              <th><spring:message code='Cache.lbl_apv_webHwpEditor'/></th> <!-- 웹한글기안기 -->
			          <td>
                        <span class="chkStyle01">
                        	<input type="checkbox" id="UseWebHWPEditYN" name="UseWebHWPEditYN" value="Y" onchange="ViewOrHideUseEditYN(this);">
                        	<label for="UseWebHWPEditYN"><span></span><spring:message code='Cache.lbl_Use'/></label>
                        </span>
                      </td>
		            </tr>
			        <tr id="tr_UseEditYN" <covi:admin hiddenWhenEasyAdmin="true" />>
		              <th rowspan="2"><spring:message code='Cache.CN_163'/></th>  <!--웹에디터-->
			          <td>
                        <div class="sp_n4_wrap">
                        <span class="chkStyle01">
                        	<input type="checkbox" id="UseEditYN" name="UseEditYN" value="Y" onchange="ViewOrHideUseEditYN(this);" checked="true">
                        	<label for="UseEditYN"><span></span><spring:message code='Cache.lbl_Use'/></label>
                        </span>
                        <select name="fmbt" id="fmbt" onchange="switchEditor();" style="display:none; width:200px; height:21px; line-height:21px; margin-left:4px; margin-bottom:5px;"><option>HTML</option><option>TAG FREE</option><option>NAMO</option></select>
                        </div>
                      </td>
		            </tr>
			        <tr>
			          <td id="td_hidBodyDefault">
                        <!--웹에디터-->
                        <input type="hidden" id="hidBodyDefault">
                        <div id="divWebEditor">	
<!-- 	                         	<script type="text/javascript" src="/covicore/resources/script/Dext5/js/dext5editor.js"></script> -->
<!--         						<script src="/covicore/resources/script/Dext5/Dext5.js" type="text/javascript"></script> -->
                        	<!-- <textarea name="testweb" id="testweb" rows="3" cols="10" style="width:93%; height:30px; overflow:scroll; overflow-x:hidden;" maxlength="256"></textarea> -->
			                <!-- <script src="/WebSite/Common/ExControls/WebEditor/WebEditor_Approval.js" type="text/javascript" language="javascript"></script> -->     
                        </div>  		  
			          </td>
		            </tr>
		          </tbody>
		        </table>
      			 <!--양식HTML(본문)정보 탭 종료 -->
      			 <!-- 양식수정 주의문구 -->
     			 <c:if test="${strisSaaS eq 'Y'}">
	     				<table class="sadmin_table sa_menuBasicSetting mb20" id ="XFormNotice" style="display:none">
	     					<colgroup>
	     					<col style="width: 100%;">
	     					</colgroup>
	     				<tbody style="text-align: center; color:red;"><tr>
	     					<td>
	     						<span><spring:message code='Cache.lbl_apv_updateFormAdmin_notice'/></span>
	     					</td>
	     				</tr>
	     				</tbody></table>
     			 </c:if>
       		</div>
       		
       		<!--부가설정 탭 시작 -->
			<div id="divOptionalSetting" class="tabContent">    
          <table class="sadmin_table sa_menuBasicSetting mb20">
	          <colgroup>
					<col width="200px;">
					<col width="*">
					<col width="200px;">
					<col width="*">
				</colgroup>
	          <tbody>
		        <tr <covi:admin hiddenWhenEasyAdmin="true" />>
	              <th><spring:message code='Cache.lbl_SecurityGrade'/></th>  <!--보안등급-->
		          <td colspan="3">
		          	<select id="SecurityGrade" name="SecurityGrade" class="w200p">
		          		<option value="100"><spring:message code='Cache.DOC_LEVEL_10'/></option>
		          		<option value="200"><spring:message code='Cache.DOC_LEVEL_20'/></option>
		          		<option value="300"><spring:message code='Cache.DOC_LEVEL_30'/></option>
		          	</select>
		          </td>
	            </tr>
		        <tr <covi:admin hiddenWhenEasyAdmin="true" />>
		        	<th><spring:message code='Cache.lbl_DocCate'/></th>  <!--문서분류-->
		        	<td colspan="3">
		        		<input type="text" id="DocClassName" name="DocClassName"  class="w200p" readOnly>
		        		<input type="hidden" id="DocClassID" name="DocClassID" />
		        		<input type="hidden" id="EntDocClassID" name="EntDocClassID" />
		        		<img src="<%=cssPath%>/approval/resources/images/Approval/btn_organization.gif" name="btn_Process" id="btn_Process" align="absMiddle" border="0" onclick="OpenDocClass();" style="cursor:pointer;" />
                     </td>
	            </tr>
		        <tr <covi:admin hiddenWhenEasyAdmin="true" />>
	              <th><spring:message code='Cache.lbl_apv_retention'/></th>  <!--보존년한-->
		          <td colspan="3">
                       <select id="PreservPeriod" name="PreservPeriod" class="w200p">
                           <option value="1">1<spring:message code='Cache.lbl_apv_year'/></option>
                           <option value="3">3<spring:message code='Cache.lbl_apv_year'/></option>
                           <option value="5">5<spring:message code='Cache.lbl_apv_year'/></option>
                           <option value="7">7<spring:message code='Cache.lbl_apv_year'/></option>
                           <option value="10">10<spring:message code='Cache.lbl_apv_year'/></option>
                           <option value="99"><spring:message code='Cache.lbl_apv_permanence'/></option>
                       </select>
                     </td>
	            </tr>
                   <tr>
	              <th><spring:message code='Cache.lbl_apv_secret_YN'/></th>  <!--기밀문서 사용-->
		          <td colspan="3" style="padding:0px;">
                       <table class="sadmin_inside_table">
                           <tr>
                               <td>
                                   <span class="chkStyle01">
                                   	<input type="checkbox" id="UseApproveSecret" name="UseApproveSecret" value="Y">
                                   	<label for="UseApproveSecret"><span></span></label>
                                   </span>
                               </td>
                           </tr>
                       </table>
                     </td>
	            </tr>			        
                   <tr>
                     <th><spring:message code='Cache.lbl_useBlocCheck'/></th>  <!--일괄확인 사용-->
		          <td style="padding:0px;">
                       <table class="sadmin_inside_table">
                           <tr>
                               <td>
                                   <span class="chkStyle01">
                                   	<input type="checkbox" id="UseBlocCheck" name="UseBlocCheck" value="Y">
                                   	<label for="UseBlocCheck"><span></span></label>
                                   </span>
                               </td>
                           </tr>
                       </table>
                     </td>
	              <th><spring:message code='Cache.msg_apv_formcreate_enbloc'/></th>  <!--일괄결재 사용-->
		          <td style="padding:0px;">
                       <table class="sadmin_inside_table">
                           <tr>
                               <td>
                                   <span class="chkStyle01">
                                   	<input type="checkbox" id="UseBlocApprove" name="UseBlocApprove" value="Y">
                                   	<label for="UseBlocApprove"><span></span></label>
                                   </span>
                               </td>
                           </tr>
                       </table>
                     </td>
	            </tr>
	            <tr <covi:admin hiddenWhenEasyAdmin="true" />>
                     <th><spring:message code='Cache.lbl_Horizontal_form'/></th>  <!--가로양식 사용-->
		          <td name="tdWideForm" style="padding:0px;">
                       <table class="sadmin_inside_table">
                           <tr>
                               <td>
                                   <span class="chkStyle01">
                                   	<input type="checkbox" id="UseWideForm" name="UseWideForm" value="Y">
                                   	<label for="UseWideForm"><span></span></label>
                                   </span>
                               </td>
                           </tr>
                       </table>
                     </td>
                     <th name="hidTH"><spring:message code='Cache.lbl_apv_otherLegacy'/></th>  <!--외부연동 사용-->
		          <td name="hidTD" style="padding:0px;">
                       <table class="sadmin_inside_table">
                           <tr>
                               <td>
                                   <span class="chkStyle01">
                                   	<input type="checkbox" id="UseOtherLegacyForm" name="UseOtherLegacyForm" value="Y">
                                   	<label for="UseOtherLegacyForm"><span></span></label>
                                   </span>
                               </td>
                           </tr>
                       </table>
                     </td>
	            </tr>
                   <tr style="display: none;" <covi:admin hiddenWhenEasyAdmin="true" />>
	              <th><spring:message code='Cache.lbl_apv_use_Notice_mail'/></th>  <!--결재 알림 사용-->
		          <td colspan="3" style="padding:0px;">
                       <table class="sadmin_inside_table">
                           <tr>
                               <td><input type="hidden" id="FmMailList" name="FmMailList" />
                                    <div id="divEntMailList" class="sp_n3_wrap" style="font-size: 12px;"></div> 
                               </td>
                           </tr>
                       </table>
                     </td>
	            </tr>
                   <tr <covi:admin hiddenWhenEasyAdmin="true" />>
	              <th><spring:message code='Cache.lbl_apv_useDeptReceiptManager'/></th>  <!--문서수발신 담당자 사용-->
		          <td colspan="3" style="padding:0px;">
                       <table class="sadmin_inside_table">
                           <tr>
                               <td>
                                   <span class="chkStyle01">
                                   	<input type="checkbox" id="UseDeptReceiptManager" name="UseDeptReceiptManager" value="Y">
                                   	<label for="UseDeptReceiptManager"><span></span></label>
                                   </span>
                               </td>
                           </tr>
                       </table>
                     </td>
	            </tr>
                   <%-- <tr data-litype='SubTableSetting'>
                       <th><spring:message code='Cache.lbl_formReportAuthority'/></th>  <!-- 집계함 조회권한자 -->
                       <td colspan="3">
                       <table>
                           <tr>                                
                               <td>
                                   <input type="text" id="TxtViewReport" name="TxtViewReport" class="AXInput" style="width:300px;" readonly="readonly" />
                                   <input type="hidden" id="HiddenViewReport" name="HiddenViewReport" />
                                   <input type="hidden" id="HiddenViewReportXML" name="HiddenViewReportXML" />
                               </td>
                               <td>
                                   <input type="button" class="AXButton"  value="<spring:message code='Cache.lbl_apv_selection'/>" onclick="OrgMap_Open(1);"/>
                               </td>
                           </tr>
                       </table>
                       </td>  
	            </tr> --%>
                   <tr>
	              <th><spring:message code='Cache.apv_btn_rule'/></th>  <!-- 전결 규정 -->
		          <td colspan="3">
					<select  name="selectEntList" class="" id="selectEntList"></select>
					<div id="ruleItemDiv" style="overflow-y: auto; height: 350px; margin-top: 10px;"></div>
                     </td>
	            </tr>                    
	          </tbody>
	        </table>
       		</div>
       		<!--부가설정 탭 종료 -->
							
			<!--하위테이블구성 탭 시작 -->  
			<div id="divSubTableSetting" class="tabContent">
	          <table class="sadmin_table sa_menuBasicSetting mb20" >
						<colgroup>
							<col id="t_tit" style="width:13%;">
							<col id="">
						</colgroup>
						<tbody>
							<!--하위마스터테이블-->
							<tr name="trMasterTable" class="lineHeight2">
								<th scope="row" colspan="2">
									<a type="checkbox" id="IsUseMaster" class="chkeckSubTableOff" value="N" onclick="IsUseSubTables(this);" ><spring:message code='Cache.lbl_apv_formcreate_subtable' /></a>
								</th>
							</tr>
							<tr name="trMasterTable">
								<td>
									<spring:message code='Cache.lbl_tableName' />
								</td>
								<td>
									<input type="text" id="MainTable" name="MainTable" title="하위마스터테이블" maxlength="30" class="" style="width:350px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled"/>
									<input type="button" id="btnCheckDupMaster" class="btnTypeDefault" value="<spring:message code='Cache.lbl_apv_DuplicateCheck'/>" onclick="checkDupSubTable(this);" disabled="disabled"/>
									<input type="hidden" id="isCheckDupMaster" value="N" />
									<span class="ml10">
										<input type="checkbox" id="CanWriteMaster" class="verticalMiddle" onchange="canWriteTableName(this);" disabled="disabled"/>
										<label class="verticalMiddle" for="CanWriteMaster">
											<spring:message code='Cache.lbl_Mail_DirectInput'/>
										</label>
									</span>
								</td>
							</tr>
							<tr name="trMasterTable">
								<td colspan="2" style="padding-top:5px;padding-bottom:10px;">
									<p class="t_2" style="margin-top:0px; float:left;">
									<span class="txt_gn12">
										<strong><spring:message code='Cache.lbl_apv_formcreate_LCODE20'/></strong>
									</span>
									<span id="MasterColmAdd" style="display: none">
										<a id="btnAddField" class="addField" onClick="addSubTableFieldRow('SubMaster_FieldTable');"></a>
										<a id="btnRemoveField" class="removeField" onClick="deleteSubTableFieldRows('SubMaster_FieldTable');"></a>
									</span>
									</p>  <!--추가 필드-->
									<div class="ztable_list">
										<table class="sadmin_table" id="SubMaster_FieldTable" name="SubMaster_FieldTable" cellpadding="0" cellspacing="0">
											<colgroup>
												<col style="width:4%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
											</colgroup>
											<tbody>
												<tr>
													<th scope="col" class="table_top_first"></th>  <!--제거-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE22'/></th>  <!--필드ID-->
													<th scope="col"><spring:message code='Cache.lbl_FieldNm'/></th>                 <!--필드명-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE24'/></th>  <!--필드속성-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE25'/></th>  <!--필드길이-->
													<th scope="col">Default</th>
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE30'/></th>  <!--객체유형-->
												</tr>
											</tbody>
										</table>
									</div>
								</td>
							</tr>
							<!-- 하위테이블1 -->
							<tr name="trSubTable1" class="lineHeight2">
								<th scope="row" colspan="2">
									<a type="checkbox" id="IsUseSub1" class="chkeckSubTableOff" value="N" onclick="IsUseSubTables(this);"><spring:message code='Cache.msg_apv_formcreate_subtable1'/></a>
								</th>
							</tr>
							<tr name="trSubTable1">
								<td>
									<spring:message code='Cache.lbl_tableName' />
								</td> 
								<td>
									<input type="text" id="SubTable1" name="SubTable1" title="하위테이블1명칭" maxlength="100" class="" style="width:350px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled" />
									<input type="button" id="btnCheckDupSub1" class="btnTypeDefault" value="<spring:message code='Cache.lbl_apv_DuplicateCheck'/>" onclick="checkDupSubTable(this);" disabled="disabled"/>
									<input type="hidden" id="isCheckDupSub1" value="N" />
									<span class="ml10">
										<input type="checkbox" id="CanWriteSub1" class="verticalMiddle" onchange="canWriteTableName(this);"disabled="disabled"/>
										<label class="verticalMiddle" for="CanWriteSub1">
											<spring:message code='Cache.lbl_Mail_DirectInput'/>
										</label>
									</span>
								</td>
							</tr>
							<tr name="trSubTable1">
								<td><spring:message code='Cache.lbl_apv_Sort'/></td><!--하위테이블1정렬-->
								<td>
									<input type="text" id="SubSort1" name="SubSort1" maxlength="100" class="" style="width:200px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled"/>
									<span class="lineHeight2"><spring:message code='Cache.msg_apv_formcreate_rowseqasc'/></span> 
								</td>
							</tr>
							<tr name="trSubTable1">
								<td colspan="2" style="padding-top:5px;padding-bottom:10px;">
									<p class="t_2" style="margin-top:0px;float:left;">
									<span class="txt_gn12">
										<strong><spring:message code='Cache.lbl_apv_formcreate_LCODE20'/></strong>
									</span>
									<span id="Sub1ColmAdd" style="display: none">
										<a id="btnAddField" class="addField" onClick="addSubTableFieldRow('Sub_FieldTable1');"></a>
										<a id="btnRemoveField" class="removeField" onClick="deleteSubTableFieldRows('Sub_FieldTable1');"></a>
									</span>
									</p>  <!--추가 필드-->
									<div class="ztable_list">
										<table class="sadmin_table" id="Sub_FieldTable1" name="Sub_FieldTable1" cellpadding="0" cellspacing="0">
											<colgroup>
												<col style="width:4%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
											</colgroup>
											<tbody>
												<tr>
													<th scope="col" class="table_top_first"></th>  <!--제거-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE22'/></th>  <!--필드ID-->
													<th scope="col"><spring:message code='Cache.lbl_FieldNm'/></th>                 <!--필드명-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE24'/></th>  <!--필드속성-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE25'/></th>  <!--필드길이-->
													<th scope="col">Default</th>
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE30'/></th>  <!--객체유형-->
												</tr>
											</tbody>
										</table>
									</div>
								</td>
							</tr>
							<!-- 하위테이블2 -->
							<tr name="trSubTable2" class="lineHeight2">
								<th scope="row" colspan="2">
									<a type="checkbox" id="IsUseSub2" class="chkeckSubTableOff" value="N" onclick="IsUseSubTables(this);"><spring:message code='Cache.msg_apv_formcreate_subtable2'/></a>
								</th>
							</tr>
							<tr name="trSubTable2">
								<td>
									<spring:message code='Cache.lbl_tableName' />
								</td> 
								<td>
									<input type="text" id="SubTable2" name="SubTable2" title="하위테이블2명칭" maxlength="100" class="" style="width:350px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled" />
									<input type="button" id="btnCheckDupSub2" class="btnTypeDefault" value="<spring:message code='Cache.lbl_apv_DuplicateCheck'/>" onclick="checkDupSubTable(this);" disabled="disabled"/>
									<input type="hidden" id="isCheckDupSub2" value="N" />
									<span>
										<input type="checkbox" id="CanWriteSub2" class="verticalMiddle" onchange="canWriteTableName(this);" disabled="disabled"/>
										<label class="verticalMiddle" for="CanWriteSub2">
											<spring:message code='Cache.lbl_Mail_DirectInput'/>
										</label>
									</span>
								</td>
							</tr>
							<tr name="trSubTable2">
								<td><spring:message code='Cache.lbl_apv_Sort'/></td><!--하위테이블2정렬-->
								<td>
									<input type="text" id="SubSort2" name="SubSort2" maxlength="100" class="" style="width:200px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled" />
									<span class="lineHeight2"><spring:message code='Cache.msg_apv_formcreate_rowseqasc'/></span>
								</td>
							</tr>
							<tr name="trSubTable2">
								<td colspan="2" style="padding-top:5px;padding-bottom:10px;">
									<p class="t_2" style="margin-top:0px;float:left;">
									<span class="txt_gn12">
										<strong><spring:message code='Cache.lbl_apv_formcreate_LCODE20'/></strong>
									</span>
									<span id="Sub2ColmAdd" style="display: none">
										<a id="btnAddField" class="addField" onClick="addSubTableFieldRow('Sub_FieldTable2');"></a>
										<a id="btnRemoveField" class="removeField" onClick="deleteSubTableFieldRows('Sub_FieldTable2');"></a>
									</span>
									</p>  <!--추가 필드-->
									<div class="ztable_list">
										<table class="sadmin_table" id="Sub_FieldTable2" name="Sub_FieldTable2" cellpadding="0" cellspacing="0">
											<colgroup>
												<col style="width:4%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
											</colgroup>
											<tbody>
												<tr>
													<th scope="col" class="table_top_first"></th>  <!--제거-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE22'/></th>  <!--필드ID-->
													<th scope="col"><spring:message code='Cache.lbl_FieldNm'/></th>                 <!--필드명-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE24'/></th>  <!--필드속성-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE25'/></th>  <!--필드길이-->
													<th scope="col">Default</th>
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE30'/></th>  <!--객체유형-->
												</tr>
											</tbody>
										</table>
									</div>
								</td>
							</tr>
							<tr name="trSubTable3" class="lineHeight2">
								<th scope="row" colspan="2">
									<a type="checkbox" id="IsUseSub3" class="chkeckSubTableOff" value="N" onclick="IsUseSubTables(this);"><spring:message code='Cache.msg_apv_formcreate_subtable3'/></a>
								</th>
							</tr>
							<tr name="trSubTable3">
								<td>
									<spring:message code='Cache.lbl_tableName' />
								</td> <!-- 하위테이블3명칭 -->
								<td>
									<input type="text" id="SubTable3" name="SubTable3" title="하위테이블3명칭" maxlength="100" class="" style="width:350px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled" />
									<input type="button" id="btnCheckDupSub3" class="btnTypeDefault" value="<spring:message code='Cache.lbl_apv_DuplicateCheck'/>" onclick="checkDupSubTable(this);" disabled="disabled"/>
									<input type="hidden" id="isCheckDupSub3" value="N" />
									<span>
										<input type="checkbox" id="CanWriteSub3" class="verticalMiddle" onchange="canWriteTableName(this);" disabled="disabled"/>
										<label class="verticalMiddle" for="CanWriteSub3">
											<spring:message code='Cache.lbl_Mail_DirectInput'/>
										</label>
									</span>
								</td>
							</tr>
							<tr name="trSubTable3">
								<td><spring:message code='Cache.lbl_apv_Sort'/></td><!--하위테이블3정렬-->
								<td>
									<input type="text" id="SubSort3" name="SubSort3" maxlength="100" class="" style="width:200px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled"/>
									<span class="lineHeight2"><spring:message code='Cache.msg_apv_formcreate_rowseqasc'/></span>
								</td>
							</tr>
							<tr name="trSubTable3">
								<td colspan="2" style="padding-top:5px;padding-bottom:10px;">
									<p class="t_2" style="margin-top:0px;float:left;">
										<span class="txt_gn12">
											<strong><spring:message code='Cache.lbl_apv_formcreate_LCODE20'/></strong>
										</span>
										<span id="Sub3ColmAdd" style="display: none">
											<a id="btnAddField" class="addField" onClick="addSubTableFieldRow('Sub_FieldTable3');"></a>
											<a id="btnRemoveField" class="removeField" onClick="deleteSubTableFieldRows('Sub_FieldTable3');"></a>
										</span>
									</p>  <!--추가 필드-->
									<div class="ztable_list">
										<table class="sadmin_table" id="Sub_FieldTable3" name="Sub_FieldTable3" cellpadding="0" cellspacing="0">
											<colgroup>
												<col style="width:4%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
											</colgroup>
											<tbody>
												<tr>
													<th scope="col" class="table_top_first"></th>  <!--제거-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE22'/></th>  <!--필드ID-->
													<th scope="col"><spring:message code='Cache.lbl_FieldNm'/></th>                 <!--필드명-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE24'/></th>  <!--필드속성-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE25'/></th>  <!--필드길이-->
													<th scope="col">Default</th>
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE30'/></th>  <!--객체유형-->
												</tr>
											</tbody>
										</table>
									</div>
								</td>
							</tr>
							<tr name="trSubTable4" class="lineHeight2">
								<th scope="row" colspan="2">
									<a type="checkbox" id="IsUseSub4" class="chkeckSubTableOff" value="N" onclick="IsUseSubTables(this);"><spring:message code='Cache.msg_apv_formcreate_subtable4'/></a>
								</th>
							</tr>
							<tr name="trSubTable4">
								<td>
									<spring:message code='Cache.lbl_tableName' />
								</td> <!-- 하위테이블4명칭 -->
								<td>
									<input type="text" id="SubTable4" name="SubTable4" title="하위테이블4명칭" maxlength="100" class="" style="width:350px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled"/>
									<input type="button" id="btnCheckDupSub4" class="btnTypeDefault" value="<spring:message code='Cache.lbl_apv_DuplicateCheck'/>" onclick="checkDupSubTable(this);" disabled="disabled"/>
									<input type="hidden" id="isCheckDupSub4" value="N" />
									<span>
										<input type="checkbox" id="CanWriteSub4" class="verticalMiddle" onchange="canWriteTableName(this);" disabled="disabled"/>
										<label class="verticalMiddle" for="CanWriteSub4">
											<spring:message code='Cache.lbl_Mail_DirectInput'/>
										</label>
									</span>
								</td>
							</tr>
							<tr name="trSubTable4">
								<td><spring:message code='Cache.lbl_apv_Sort'/></td><!--하위테이블4정렬-->
								<td>
									<input type="text" id="SubSort4" name="SubSort4" maxlength="100" class="" style="width:200px;" onkeydown="event_inputKeyDown(event, this);" disabled="disabled"/>
									<span class="lineHeight2"><spring:message code='Cache.msg_apv_formcreate_rowseqasc'/></span> 
								</td>
							</tr>
							<tr name="trSubTable4">
								<td colspan="2" style="padding-top:5px;padding-bottom:10px;">
									<p class="t_2" style="margin-top:0px;float:left;">
										<span class="txt_gn12">
											<strong><spring:message code='Cache.lbl_apv_formcreate_LCODE20'/></strong>
										</span>
										<span id="Sub4ColmAdd" style="display: none">
											<a id="btnAddField" class="addField" onClick="addSubTableFieldRow('Sub_FieldTable4');"></a>
											<a id="btnRemoveField" class="removeField" onClick="deleteSubTableFieldRows('Sub_FieldTable4');"></a>
										</span>
									</p>  <!--추가 필드-->
									<div class="ztable_list">
										<table class="sadmin_table" id="Sub_FieldTable4" name="Sub_FieldTable4" cellpadding="0" cellspacing="0">
											<colgroup>
												<col style="width:4%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
												<col style="width:16%;">
											</colgroup>
											<tbody>
												<tr>
													<th scope="col" class="table_top_first"></th>  <!--제거-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE22'/></th>  <!--필드ID-->
													<th scope="col"><spring:message code='Cache.lbl_FieldNm'/></th>                 <!--필드명-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE24'/></th>  <!--필드속성-->
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE25'/></th>  <!--필드길이-->
													<th scope="col">Default</th>
													<th scope="col"><spring:message code='Cache.lbl_apv_formcreate_LCODE30'/></th>  <!--객체유형-->
												</tr>
											</tbody>
										</table>
									</div>
								</td>
							</tr>
							<tr name="trHiddenMg" val="0" style="display:none;">
								<td colspan="2" style="padding-top:5px;padding-bottom:10px;height:300px;text-align:center;">
									<textarea id="hidFormFieldText" cols="50" rows="5" style="width:98%;height:98%"></textarea><br />
									<input type="button" name="btnSetSubTableInfo" value="Setting SubTableInfo" onclick="settingSubTableInfo()" style="height:28px;margin-top:10px;" />
								</td>
							</tr>
			         	</tbody>
		        </table>
        <!--하위테이블구성 탭 종료 -->	                
			</div>								
			<div id="divAttributeInfo" class="tabContent">					
          	<table class="sadmin_table sa_menuBasicSetting mb20" cellpadding="0" cellspacing="0">
	          <colgroup>
		        <col width="200px;">
		        <col width="*">
	          </colgroup>
	          <tbody>
	            <tr>
	              <th><spring:message code='Cache.lbl_NoteCreateLayout'/></th>  <!-- 참고사항 -->
		          <td>
		          		<input type="text" id="DocHelpApproval" name="DocHelpApproval" class="w200p" />
                        <input type="hidden" id="DocHelpApprovalImages" name="DocHelpApprovalImages" value="" />
                        <input type="hidden" id="IsDocHelpApprovalEdit" name="IsDocHelpApprovalEdit" value="N" />
                        <a href="#" id="btDocHelpApproval" onclick="setDocEditorApproval('Help');" class="btnTypeDefault"><spring:message code='Cache.btn_apv_Write'/></a>
                        <span class="chkStyle01 ml20"><input type="checkbox" id="UseDocHelpApproval" name="UseDocHelpApproval" value="Y"><label for="UseDocHelpApproval"><span></span><spring:message code='Cache.lbl_apv_formcreate_LCODE13'/></label></span> <!--사용-->
                     </td>  
	            </tr>                      
	            <tr>
	              <th><spring:message code='Cache.lbl_NoticePopup'/></th>  <!-- 팝업 공지 -->
		          <td>
		          		<input type="text" id="DocPopupApproval" name="DocPopupApproval" class="w200p" />
                        <input type="hidden" id="DocPopupApprovalImages" name="DocPopupApprovalImages"  value=""/>
                        <input type="hidden" id="IsDocPopupApprovalEdit" name="IsDocPopupApprovalEdit" value="N" />
                        <a href="#" id="btDocPopupApproval" onclick="setDocEditorApproval('Popup');" class="btnTypeDefault"><spring:message code='Cache.btn_apv_Write'/></a>
                        <span class="chkStyle01 ml20"><input type="checkbox" id="UseDocPopupApproval" name="UseDocPopupApproval" value="Y"><label for="UseDocPopupApproval"><span></span><spring:message code='Cache.lbl_auto_popup'/></label></span>
                        <span class="chkStyle01 ml20"><input type="checkbox" id="UseDocPopupBtn" name="UseDocPopupBtn" value="Y"><label for="UseDocPopupBtn"><span></span><spring:message code='Cache.lbl_head_helptext'/></label></span>
                     </td>  
	            </tr>
	          </tbody>
	        </table> 
			</div>
			<div id="divAutoApprovalLine" style="" class="tabContent">
				<table class="sadmin_table autoApp">
					<tbody>
						<tr>
				          	<td rowspan="2" class="autoBox01">
				            	<dl class="autoTit01">
				                	<dt><spring:message code='Cache.lbl_apv_PostReferrer'/><!-- 사후참조자 --></dt>
				                    <dd class="onOff" id="ddCCAfter"><a id="deptCCAfter" value="deptCCAfter" onclick="changeDeptAndRegion(this)" ><spring:message code='Cache.lbl_Enterprise_By'/><!-- 계열사별 --></a><a id="regionCCAfter" value="regionCCAfter"onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Workplace_by'/><!-- 사업장별 --></a></dd>
				                </dl>
				            </td>
				            <td rowspan="2" class="autoBox02">
				            	<a id="coviTreeTarget02_AX_tree_focus" href="#axtree"></a>
					          	<div id="CCAfterTree" style="width:100%; height:150px; "></div>
					          	<div id="CCAfterRegionTree" style="width:100%; height:150px; display: none;" ></div>			          	
					        </td>
					        <td rowspan="2" class="autoBox03">
					        	<div id="divCCAfter" class="nameArea"></div>
					          	<div id="divCCAfterRegion" class="nameArea""></div>			      
					          	<div class="nameAdd" style="position: relative;"><a class="smButton" href="#ax" onclick="OrgMap_Open('CCAfter'); return false;"><spring:message code='Cache.btn_apv_add'/><!-- 추가 --></a></div>
					        </td>
					        <td class="autoBox04">			          	
					          	<a type="checkbox" name="UseDocAutoCcSet" id="UseDocAutoCcSet" class="ckeckOff" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Automatic_settings'/><!-- 자동세팅 --></a>		
						</tr>
						<tr class="autoBox05">
					        <td rowspan="2" class="autoBox05">
		           				<a type="checkbox" name="UseDocAutoCcChk" id="UseDocAutoCcChk" class="ckeckOff" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Prerequisite_check'/><!-- 필수체크 --></a>
		          			</td>
          				</tr>
					</tbody>
          		</table>
		        <table class="sadmin_table autoApp">
		        	<tbody>
		        		<tr>
				        	<td rowspan="2" class="autoBox01">
				            	<dl class="autoTit02">
				                	<dt><spring:message code='Cache.lbl_apv_AdvanceReferrers'/><!-- 사전참조자 --></dt>
				                    <dd class="onOff" id="ddCCBefore"><a id="deptCCBefore" value="deptCCBefore" onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Enterprise_By'/><!-- 계열사별 --></a><a id="regionCCBefore" value="regionCCBefore" onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Workplace_by'/><!-- 사업장별 --></a></dd>
				                </dl>
				            </td>
					        <td rowspan="2" class="autoBox02">
					          	<div id="CCBeforeTree" style="width:100%; height:150px; "></div>
					          	<div id="CCBeforeRegionTree" style="width:100%; height:150px; display: none;" ></div>
					        </li>
					        <td rowspan="2" class="autoBox03">
					          	<div id="divCCBefore" class="nameArea"></div>
					          	<div id="divCCBeforeRegion" class="nameArea"></div>
					          	<div class="nameAdd" style="position: relative;"><a class="smButton" href="#ax" onclick="OrgMap_Open('CCBefore'); return false;"><spring:message code='Cache.btn_apv_add'/><!-- 추가 --></a></div>
					        </td>
				            <td class="autoBox04">
				            	<a class="ckeckOff" name="UseDocAutoCcBeforeSet" id="UseDocAutoCcBeforeSet" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Automatic_settings'/><!-- 자동세팅 --></a>                
				            </td>
						</tr>
						<tr>
				            <td class="autoBox05">
				            	<a class="ckeckOff" name="UseDocAutoCcBeforeChk" id="UseDocAutoCcBeforeChk" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Prerequisite_check'/><!-- 필수체크 --></a>
				            </td>	
		            	</tr>
		            </tbody>
		        </table>		
		        <table class="sadmin_table autoApp">
		        	<tbody>
		        		<tr>
				        	<td rowspan="2" class="autoBox01">
				            	<dl class="autoTit03">
				                	<dt><spring:message code='Cache.lbl_ApprovalUser'/><!-- 결재자 --></dt>
				                    <dd class="onOff" id="ddApproval"><a id="deptApproval" value="deptApproval" onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Enterprise_By'/><!-- 계열사별 --></a><a id="regionApproval" value="regionApproval" onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Workplace_by'/><!-- 사업장별 --></a></dd>
				                </dl>
				            </td>
					        <td rowspan="2" class="autoBox02">
					          	<div id="ApprovalTree" style="width:100%; height:150px; "></div>
					          	<div id="ApprovalRegionTree" style="width:100%; height:150px; display: none;" ></div>
					          	
					        </td>
					        <td rowspan="2" class="autoBox03">
					          	<div id="divApproval" class="nameArea"></div>
					          	<div id="divApprovalRegion" class="nameArea"></div>
					          	<div class="nameAdd" style="position: relative;"><a class="smButton" href="#ax" onclick="OrgMap_Open('Approval'); return false;"><spring:message code='Cache.btn_apv_add'/><!-- 추가 --></a></div>			          	
					        </td>
				            <td class="autoBox04">
				            	<a class="ckeckOff" name="UseDocAutoApprovalSet" id="UseDocAutoApprovalSet" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Automatic_settings'/><!-- 자동세팅 --></a>                
				            </td>
				        </tr>
						<tr>
				            <td class="autoBox05">
				            	<a class="ckeckOff" name="UseDocAutoApprovalChk" id="UseDocAutoApprovalChk" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Prerequisite_check'/><!-- 필수체크 --></a>
				            </td>
		        		</tr>
		            </tbody>
		        </table>
			    <table class="sadmin_table autoApp">
		        	<tbody>
		        		<tr>
				        	<td rowspan="2" class="autoBox01">
				            	<dl class="autoTit04">
				                	<dt><spring:message code='Cache.lbl_apv_Agreement'/><!-- 합의자 --></dt>
				                    <dd class="onOff" id="ddAgree"><a id="deptAgree" value="deptAgree" onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Enterprise_By'/><!-- 계열사별 --></a><a id="regionAgree" value="regionAgree" onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Workplace_by'/><!-- 사업장별 --></a></dd>
				                </dl>
				            </td>
					        <td rowspan="2" class="autoBox02">
					          	<div id="AgreeTree" style="width:100%; height:150px; "></div>
					          	<div id="AgreeRegionTree" style="width:100%; height:150px; display: none;" ></div>
					        </td>
					        <td rowspan="2" class="autoBox03">
					          	<div id="divAgree" class="nameArea"></div>
					          	<div id="divAgreeRegion" class="nameArea"></div>	
					          	<div class="nameAdd" style="position: relative;">
					          		<a class="smButton" href="#ax" onclick="OrgMap_Open('Agree'); return false;"><spring:message code='Cache.btn_apv_add'/><!-- 추가 --></a>
					          		<a class="ckeckOff" name="IsSerialAgree" id="IsSerialAgree" onclick="checkUseDocAuto(this)" style="margin-left: 10px; display: none;"><span style="font-size: 13px;"><spring:message code='Cache.lbl_apv_serial'/><!-- 순차 --></span></a>
					          	</div>			          	
					       </td>
				            <td class="autoBox04">
				            	<a class="ckeckOff" name="UseDocAutoAgreeSet" id="UseDocAutoAgreeSet" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Automatic_settings'/><!-- 자동세팅 --></a>                
				            </td>
				        </tr>
						<tr>
				            <td class="autoBox05">
				            	<a class="ckeckOff"  name="UseDocAutoAgreeChk" id="UseDocAutoAgreeChk" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Prerequisite_check'/><!-- 필수체크 --></a>
				            </td>		
						</tr>
		            </tbody>
		        </table>	        				
			    <table class="sadmin_table autoApp">
		        	<tbody>
		        		<tr>
				        	<td rowspan="2" class="autoBox01">
				            	<dl class="autoTit04">
				                	<dt><spring:message code='Cache.lbl_apv_assistPerson'/><!-- 협조자 --></dt>
				                    <dd class="onOff" id="ddAssist"><a id="deptAssist" value="deptAssist" onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Enterprise_By'/><!-- 계열사별 --></a><a id="regionAssist" value="regionAssist" onclick="changeDeptAndRegion(this)"><spring:message code='Cache.lbl_Workplace_by'/><!-- 사업장별 --></a></dd>
				                </dl>
				            </td>
					        <td rowspan="2" class="autoBox02">
					          	<div id="AssistTree" style="width:100%; height:150px; "></div>
					          	<div id="AssistRegionTree" style="width:100%; height:150px; display: none;" ></div>
					        </td>
					        <td rowspan="2" class="autoBox03">
					          	<div id="divAssist" class="nameArea"></div>
					          	<div id="divAssistRegion" class="nameArea"></div>	
					          	<div class="nameAdd" style="position: relative;">
					          		<a class="smButton" href="#ax" onclick="OrgMap_Open('Assist'); return false;"><spring:message code='Cache.btn_apv_add'/><!-- 추가 --></a>
					          		<a class="ckeckOff" name="IsSerialAssist" id="IsSerialAssist" onclick="checkUseDocAuto(this)" style="margin-left: 10px; display: none;"><span style="font-size: 13px;"><spring:message code='Cache.lbl_apv_serial'/><!-- 순차 --></span></a>
					          	</div>			          	
					       </td>
				            <td class="autoBox04">
				            	<a class="ckeckOff" name="UseDocAutoAssistSet" id="UseDocAutoAssistSet" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Automatic_settings'/><!-- 자동세팅 --></a>                
				            </td>
				        </tr>
						<tr>
				            <td class="autoBox05">
				            	<a class="ckeckOff"  name="UseDocAutoAssistChk" id="UseDocAutoAssistChk" onclick="checkUseDocAuto(this)"><spring:message code='Cache.lbl_Prerequisite_check'/><!-- 필수체크 --></a>
				            </td>			        
						</tr>
		            </tbody>
		        </table>
		        			
			</div>
			<div id="optionTab_dept" class="tabContent">
				
			</div>
			<div id="optionTab_link" class="tabContent">
				
			</div>
			<div id="optionTab_etc" class="tabContent">
				
			</div>
			
			<div class="bottomBtnWrap">
				<a id="btnXForm" href="#" class="btnTypeDefault" onclick="btnXForm_Click();" style="display:none"><spring:message code="Cache.btn_xform_editor"/></a>
				<a id="btnSave" href="#" class="btnTypeDefault btnTypeBg" onclick="btnSave_Click();"><spring:message code="Cache.btn_apv_save"/></a>
				<a id="btnDelete" href="#" class="btnTypeDefault" onclick="btnDelete_Click();" style="display:none" ><spring:message code="Cache.btn_apv_delete"/></a>
				<a id="btnClose" href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
			</div>
		</div>
	</div>
	
	<input type="hidden" id="fmid" name="fmid" />
	<input type="hidden" id="scid" name="scid" />
	<input type="hidden" id="scnm" name="scnm" />
	<input type="hidden" id="clid" name="clid" />
	<input type="hidden" id="clnm" name="clnm" />
</form>
<script>	
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramFormID =  param[1].split('=')[1];
	var gCurrVer;
	var gOldData; // 이전 설정 데이터
	var arrEntCode = []; // 권한있는 회사 목록
	
	var flag = "0"; //부서,사용자구분용
	var objSchemaList = new Object();
	var gOpenMode;
	var AutoApprovalLineKey;
	//var AutoApprovalLineDept;
	var CCAfterTreeClickDept;
	var CCBeforeTreeClickDept;
	var ApprovalTreeClickDept;
	var AgreeTreeClickDept;	
	var AssistTreeClickDept;	
	
	var CCAfterTreeClickRegion;
	var CCBeforeTreeClickRegion;
	var ApprovalTreeClickRegion;
	var AgreeTreeClickRegion;
	var AssistTreeClickRegion;
	
	var TreeData;
	var TreeDataRegion;
	
	var OrgFileEntCode;
	var getFormClassID;
	var getSchemaID;
	
	var g_editorTollBar = '0';	// 0, 1, 2 
	var gx_id = 'xfe';
	var g_id = 'tagfe';
	var g_heigth = '400';
	var g_isLoadEditor = false;

	var g_editorKind = Common.getBaseConfig('EditorType');
	var g_companyCode = "";
	
	var ruleItemLists = new Array();		// 전결 리스트
	
	$(document).ready(function(){
		if(parent && parent.confMenu) g_companyCode = parent.confMenu.domainCode;
		else g_companyCode = Common.getSession("DN_Code");
		var sIconSelectorHtml ='';
		for (var i=1;i<=40;i++){
		    sIconSelectorHtml += '<label data-type="'+i+'"><input type="radio" name="icon" '+(i == 1 ? 'checked' : '')+'><i></i></label>';
		}
		$(".form_icon_selector").html(sIconSelectorHtml);
		Common.toolTip($("#btn_FormIcon"), "ToolTip_FormIcon", "width:400px;top:10px;"); // 양식아이콘 툴팁
		
		setEntList();
		setTreeData();		
		setRegionTreeData();
		coviInput.setSwitch();
		
		// 양식명 다국어 세팅
		coviDic.renderInclude('dic', {
			//lang : langCode,
			lang : 'ko',
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh',
			dicCallback : '',
			popupTargetID : '',
			init : '',
			styleType : 'U'
		});
		//$("#dic").find(".AXFormTable").css("box-shadow", "none");
		//$("#dic").find(".AXFormTable tbody td").css("border-right", "0px !important");
		//$("#dic").find(".AXFormTable tbody th:last").css("border-bottom", "0px");
		$("#dic").find("table.sadmin_table").addClass("sadmin_inside_table");
		
		setEnableOpt();
		
		if(mode=="modify"){
			$("#btnDelete").show();
			setData();	
			lockField();
			$('#trFormCreateKind').css({"display":"none"});
		}
		
		if(mode=="SaveAs"){	
			$("#btnSave").val("<spring:message code='Cache.lbl_VersionUp'/>");
			setData();
			lockFieldVersion();
		}
		
		if(mode == "add"){
			$("#selectCompanyCode").val(g_companyCode).prop("selected", true);
		}
		
		setselclass();
		setselschema();
		
		// 전결 규정
		setRuleItemDiv($("#selectEntList").val(),"load");
		$("#selectEntList").on('change', function(){
			setRuleItemDiv($("#selectEntList").val(), "selected");
		});
		/*
		$("#selectEntList").bindSelect({
			onchange: function(){
				setRuleItemDiv($("#selectEntList").val(), "selected");
			}
		});		
		*/
		
		// 공공데모는 불필요항목 가리기
		if(location.href.indexOf("gov.covismart.com") > -1) {
			$("input[name='MobileFormYN']").closest("tr").css("display", "none");
			
			$("#ddCCAfter").css("display", "none");
			$("#ddCCBefore").css("display", "none");
			$("#ddApproval").css("display", "none");
			$("#ddAgree").css("display", "none");
			$("#ddAssist").css("display", "none");
			
			$("td[name=hidTD]").css("display", "none");
			$("th[name=hidTH]").css("display", "none");
			$("td[name=tdWideForm]").attr("colspan", "3");
		}
		
		$("#fmpf,#MainTable,#SubTable1,#SubTable2,#SubTable3,#SubTable4")
		.on("keyup", function(){
			//'_' 또는 영문 또는 숫자만 입력 가능
			$(this).val($(this).val().replace(/[^A-Za-z0-9_]/gi,''));
		}).on("blur", function(){
			if($(this).val() && !new RegExp(/^[A-Za-z][A-Za-z0-9_]*$/).test($(this).val())){
				Common.Warning("<spring:message code='Cache.msg_apv_chkInputTbName'/>");//"영어, 숫자, 언더바(_) 만 입력 가능합니다.";				
				$(this).val("");
			}
		});
		
		ViewOrHideUseEditYN($("#UseEditYN"));
		
		DisableSpecificOpt($("#MobileFormYN"));
		DisableSpecificOpt($("#UseMultiEditYN"));
		
		setEasyAdmFormat();
		$("#popBox").show();
	});
	
	function onLoadWebEditor(){
		g_isLoadEditor = true;
		
		if($("#hidBodyDefault").val() != "")
			coviEditor.setBody(g_editorKind, g_id, $("#hidBodyDefault").val());
	}
	
	// 특정 옵션은 유관 기초설정으로 사용여부 체크 후 조회
	function setEnableOpt() {
	    if (Common.getBaseConfig("useMobileApprovalWrite") == "Y" && !$("#trMobileFormYN").is("[visiblefixed]")) { // 간편관리자로인해 가려진경우 제외
			// 모바일 기안 시 모바일 양식 사용 여부 옵션 활성화
			$("#trMobileFormYN").show();
	    }
	    
	    if (Common.getBaseConfig("useMultiDraft") == "Y" && !$("#trUseMultiEditYN").is("[visiblefixed]")) {
			// 다안기안 시용 시 다안기안 사용 여부 옵션 활성화
	        $("#trUseMultiEditYN").show();
	    }
	}
	
	//계열사별 사업장별 change
	function changeDeptAndRegion(pObj){		
		var objVal = $(pObj).attr("value")
		if (objVal == "deptCCAfter") {
			$("#CCAfterTree").show();
			$("#CCAfterRegionTree").hide();
			$("#ddCCAfter").attr('class','onOff');
		}
		if (objVal == "regionCCAfter") {
			$("#CCAfterTree").hide();
			$("#CCAfterRegionTree").show();
			$("#ddCCAfter").attr('class','offOn');
		}
		if (objVal == "deptCCBefore") {
			$("#CCBeforeTree").show();
			$("#CCBeforeRegionTree").hide();
			$("#ddCCBefore").attr('class','onOff');
		}
		if (objVal == "regionCCBefore") {
			$("#CCBeforeTree").hide();
			$("#CCBeforeRegionTree").show();
			$("#ddCCBefore").attr('class','offOn');
		}		
		if (objVal == "deptApproval") {
			$("#ApprovalTree").show();
			$("#ApprovalRegionTree").hide();
			$("#ddApproval").attr('class','onOff');
		}
		if (objVal == "regionApproval") {
			$("#ApprovalTree").hide();
			$("#ApprovalRegionTree").show();
			$("#ddApproval").attr('class','offOn');
		}		
		if (objVal == "deptAgree") {
			$("#AgreeTree").show();
			$("#AgreeRegionTree").hide();
			$("#ddAgree").attr('class','onOff');
		}
		if (objVal == "regionAgree") {
			$("#AgreeTree").hide();
			$("#AgreeRegionTree").show();
			$("#ddAgree").attr('class','offOn');
		}		
		if (objVal == "deptAssist") {
			$("#AssistTree").show();
			$("#AssistRegionTree").hide();
			$("#ddAssist").attr('class','onOff');
		}
		if (objVal == "regionAssist") {
			$("#AssistTree").hide();
			$("#AssistRegionTree").show();
			$("#ddAssist").attr('class','offOn');
		}			
	}
	
	//자동결재선 자동셋팅,필수체크
	function checkUseDocAuto(pObj){	
		var objClass = $(pObj).attr("class")
	
		if(objClass=="ckeckOn"){
			$(pObj).attr("class","ckeckOff");
		}else if(objClass=="ckeckOff"){
			$(pObj).attr("class","ckeckOn");				
		}		
		
		// 합의/협조자 순차 사용 여부 체킹
		if($(pObj).attr("id").indexOf("IsSerial") > -1) {
			var scode = $(pObj).attr("scode");
			var jsonVal;
			
			if($(pObj).attr("id").indexOf("Agree") > -1){
				jsonVal = JSON.parse($("#divAgree").find("#ipt"+scode).val());
			}else{
				jsonVal = JSON.parse($("#divAssist").find("#ipt"+scode).val());
			}
			
			if(objClass=="ckeckOn"){
				jsonVal.isSerial = "N";
			}else if(objClass=="ckeckOff"){
				jsonVal.isSerial = "Y";			
			}
			
			if($(pObj).attr("id").indexOf("Agree") > -1){
				$("#divAgree").find("#ipt"+scode).val(JSON.stringify(jsonVal));
			}else{
				$("#divAssist").find("#ipt"+scode).val(JSON.stringify(jsonVal));
			}
		}
	}
	
	
	// 탭 클릭 이벤트
	function clickTab(pObj){
		var strObjName = $(pObj).attr("value");
		//$(".AXTab").attr("class","AXTab");
		//$(pObj).addClass("AXTab on");
	
		//$("#divFormBasicInfo").hide();
		//$("#divFormHtmlnfo").hide();
		//$("#divOptionalSetting").hide();
		//$("#divSubTableSetting").hide();
		//$("#divAttributeInfo").hide(); 
		//$("#divAutoApprovalLine").hide();
		$('.tabMenu>li').removeClass('active');
		$('.tabContent').removeClass('active');
		$(pObj).closest("li").addClass("active");
		$("#" + strObjName).addClass("active");
		
		$("#divCCAfterRegion").hide();
		$("#divCCBeforeRegion").hide();
		$("#divApprovalRegion").hide();
		$("#divAgreeRegion").hide();
		$("#divAssistRegion").hide();
		
		//$("#divSchemaInfo div").hide();
		//$("#" + strObjName).height();
		//$("#" + strObjName).show();
		coviInput.setDate();		
		$("#divNewCreate").show();
		
		if(strObjName=="divFormHtmlnfo" && mode=="modify"){
			var XformEditorUse = Common.getBaseConfig('XformEditorUse');
			if(XformEditorUse == "Y"){
				$("#btnXForm").show();
				if(Common.getDic('lbl_apv_updateFormAdmin_notice')!='lbl_apv_updateFormAdmin_notice'){
					$("#XFormNotice").show();
				}
			}
		}else{
			$("#btnXForm").hide();
		}
		
		//axisj selectbox로인한 호출
		//selSelectbind();
		
		ChangeFormCreateKind($("#FormCreateKind").val());
		
		if(strObjName == "divFormHtmlnfo" && $("#tagfeFrame").length == 0){
			coviEditor.loadEditor(
	    			'divWebEditor',
	    		{
	    			editorType : g_editorKind,
	    			containerID : g_id,
	    			frameHeight : '600',
	    			focusObjID : '',
	    			onLoad : 'onLoadWebEditor'
	    		}
	    	);
		}
	}
	
	// 필드 disable & invisible
	function lockField() {
		
	    $("#fmpf").attr("disabled", "true");
	    $("#fmrv").attr("disabled", "true");
	    if(mode == "modify" && '${strisSaaS}' == "Y"){ $("#selectCompanyCode").attr("disabled", "true"); }
	    
	    //$("#btApvLine").css("display", "block");
	    $("#btnAddField").css("display", "none");
	    $("#btnRemoveField").css("display", "none");
	    //$("#btUploadThumbnail").css("display", "block");
		
	    //하위테이블구성탭 추가필드 추가/삭제 버튼 숨기기
	    $("a[id=btnAddField]").hide();
	    $("a[id=btnRemoveField]").hide();
	   
	    //하위테이블 필드 disabled
	    //[2015-11-05 LeeSM] 수정, 읽기 모드 등에서 SP 명 변경 불가하도록 수정
	    $("#SubTableSPName").attr("disabled", "disabled");
	    $("#MainTable").attr("disabled", "disabled");
	    $("input[id^=SubTable], input[id^=SubSort]").attr("disabled", "disabled");
	    $('#trFormCreateKind').css({"display":"none"});
	   
	    $("a[id^=IsUse]").attr("class", "");
	    $("input[id^=CanWrite]").parent().hide();
	    $("input[id^=btnCheckDup]").hide();
	    $("table[id*=_FieldTable]").find("input,select").attr("disabled", "disabled");
	}
	
	// 버젼업용 필드 disable & invisible
	function lockFieldVersion() {
	    $("#fmpf").attr("disabled", "true");
	    //$("#fmnm").attr("disabled", "true");
	    $("#ko_full").attr("disabled", "true");
	    $("#en_full").attr("disabled", "true");
	    $("#ja_full").attr("disabled", "true");
	    $("#zh_full").attr("disabled", "true");
	    
	    // 로딩시에 AXSelect가아니므로 이미 동작하지 않았고, 불필요함  
	    //$("#selclass").bindSelectDisabled(true);
	    //$("#selschema").bindSelectDisabled(true);
	    $('#trFormCreateKind').css({"display":"none"});
	    $("#divSubTableSetting").find("input,select").attr("disabled", "true");
	}
	
	function btnXForm_Click(){
		window.open('/approval/approval_XForm.do?formID='+paramFormID);
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	// 수정모드일 시 data setting
	function setData() {
		var JSONObj;
	
		$.ajax({
			url:"getAdminFormData.do",
			type:"post",
			data:{
				FormID : paramFormID
			},
			async:false,
			success:function (data) {
				gOldData = data;
				getFormClassID = data.list[0].FormClassID;
				getSchemaID = data.list[0].SchemaID;
				$("#fmst").val(data.list[0].IsUse); //$("#fmst").bindSelectSetValue(data.list[0].IsUse);
				$("#fmrv").val(data.list[0].Revision);
				$("#fmsk").val(data.list[0].SortKey);
				
				//$("#fmnm").val(data.list[0].FormName         );
				$("#ko_full").val(data.list[0].FormName.split(";")[0]);
				try { // 기존데이터에서 오류 발생할 수 있음.
	 				$("#en_full").val(data.list[0].FormName.split(";")[1]);
	 				$("#ja_full").val(data.list[0].FormName.split(";")[2]);
	 				$("#zh_full").val(data.list[0].FormName.split(";")[3]);
				} catch(e) { coviCmn.traceLog(e); }
 				
				$("#fmpf").val(data.list[0].FormPrefix);
				$("#fmds").val(data.list[0].FormDesc);
				$("#flnm").val(data.list[0].FileName);
				
				//setTimeout(function () {
					//coviEditor.setBody('dext5', g_id, data.list[0].BodyDefault);
					$("#hidBodyDefault").val(data.list[0].BodyDefault);
				//}, 500);
				//setTimeout(function () { DEXT5.setBodyValueEx(data.list[0].BodyDefault, gx_id); }, 500);
				$("#fmbt").val(data.list[0].BodyType);				
				$("#DocHelpApproval").val(data.list[0].FormHelperContext);
				$("#DocPopupApproval").val(data.list[0].FormNoticeContext);
				$("#selectCompanyCode").val(data.list[0].CompanyCode).prop("selected", true);
				
				if(data.item.length > 0){
					parent._setParamdataAuth = {"item" : data.item};
				}else{
					parent._setParamdataAuth = {}; 
				}
				
				if(Object.keys(parent._setParamdataAuth).length == 0 || (parent._setParamdataAuth.item && parent._setParamdataAuth.item.length == 0)){
					$("#AclAllYN_Y").prop("checked", true).trigger("change");
				}else{
					$("#AclAllYN_N").prop("checked", true).trigger("change");
				}
				var idx = data.list[0].FormIcon || '1';
				$(".form_icon_selector label[data-type='"+idx+"'] input").prop("checked",true);
				
				gCurrVer = $("#fmrv").val();  //DB에저장된 현재버젼
				
				var ExtInfo = data.list[0].ExtInfo;
				
				if(!axf.isEmpty(ExtInfo)){
					var ExtInfodata = ExtInfo;					
					 $("#FormCreateKind").val(ExtInfodata.FormCreateKind);
					 $("#SecurityGrade").val(ExtInfodata.SecurityGrade);
					 $("#DocClassName").val(ExtInfodata.DocClassName);
					 $("#DocClassID").val(ExtInfodata.DocClassID);
					 $("#EntDocClassID").val(JSON.stringify(ExtInfodata.EntDocClassID));
					 $("#PreservPeriod").val(ExtInfodata.PreservPeriod);
					 $("#UnifiedFormYN").val(ExtInfodata.UnifiedFormYN); 
					 $("#MobileFormYN").val(ExtInfodata.MobileFormYN); //20180601
					 $("#UseEditYN").val(ExtInfodata.UseEditYN);
					 $("#UseMultiEditYN").val(ExtInfodata.UseMultiEditYN);
					 $("#UseHWPEditYN").val(ExtInfodata.UseHWPEditYN);
					 $("#UseWebHWPEditYN").val(ExtInfodata.UseWebHWPEditYN);
					 $("#UseBlocCheck").val(ExtInfodata.UseBlocCheck);
					 $("#UseBlocApprove").val(ExtInfodata.UseBlocApprove);
					 $("#UseWideForm").val(ExtInfodata.UseWideForm);
					 $("#UseOtherLegacyForm").val(ExtInfodata.UseOtherLegacyForm);
					 $("#UseDeptReceiptManager").val(ExtInfodata.UseDeptReceiptManager); //20200821
					 $("#UseApproveSecret").val(ExtInfodata.UseApproveSecret);
					 $("#FmMailList").val(ExtInfodata.FmMailList);
					 $("#UseDocHelpApproval").val(ExtInfodata.UseDocHelpApproval);
					 $("#UseDocPopupApproval").val(ExtInfodata.UseDocPopupApproval);
					 $("#UseDocPopupBtn").val(ExtInfodata.UseDocPopupBtn);
					 $("#TxtViewReport").val(ExtInfodata.TxtViewReport);
					 $("#HiddenViewReport").val(ExtInfodata.HiddenViewReport);
					 $("#MainTable").val(ExtInfodata.MainTable);
					 $("#SubTable1").val(ExtInfodata.SubTable1);
					 $("#SubSort1").val(ExtInfodata.SubSort1);
					 $("#SubTable2").val(ExtInfodata.SubTable2);
					 $("#SubSort2").val(ExtInfodata.SubSort2);
					 $("#SubTable3").val(ExtInfodata.SubTable3);
					 $("#SubSort3").val(ExtInfodata.SubSort3);
					 $("#SubTable4").val(ExtInfodata.SubTable4);
					 $("#SubSort4").val(ExtInfodata.SubSort4);
					 
					 // 하위테이블 사용버튼 없애기
					 $('.chkeckSubTableOff').attr("onclick", "");
					 
					 if($("#UnifiedFormYN").val()=="Y"){
						 $("#UnifiedFormYN").prop("checked",true);	
					 }else{
						 $("#UnifiedFormYN").prop("checked",false);	
					 }

					 if($("#MobileFormYN").val()=="Y"){ //모바일 양식 여부 //20180601
						 $("#MobileFormYN").prop("checked",true);	
					 }else{
						 $("#MobileFormYN").prop("checked",false);	
					 }
					 
					 if($("#UseEditYN").val()=="Y"){ //웹에디터사용유무
						 $("#UseEditYN").prop("checked",true);	
					 }else{
						 $("#UseEditYN").prop("checked",false);	
					 }
					 
					 if($("#UseHWPEditYN").val()=="Y"){ //HWP Active X 사용유무 //20180411
						 $("#UseHWPEditYN").prop("checked",true);	
					 }else{
						 $("#UseHWPEditYN").prop("checked",false);	
					 }
					 
					 if($("#UseWebHWPEditYN").val()=="Y"){ //웹한글기안기 사용유무 //20200806
						 $("#UseWebHWPEditYN").prop("checked",true);	
					 }else{
						 $("#UseWebHWPEditYN").prop("checked",false);	
					 }
					 
					//다안기안 설정 사용유무
					 if($("#UseMultiEditYN").val()=="Y"){ 
						 $("#UseMultiEditYN").prop("checked",true);	
					 }else{
						 $("#UseMultiEditYN").prop("checked",false);	
					 }	
					 
					//양식 도움말 사용
					 if($("#UseDocHelpApproval").val()=="Y"){
						 $("#UseDocHelpApproval").prop("checked",true);	
					 }else{
						 $("#UseDocHelpApproval").prop("checked",false);	
					 }

				    //팝업 공지 자동 사용
					 if($("#UseDocPopupApproval").val()=="Y"){
						 $("#UseDocPopupApproval").prop("checked",true);	
					 }else{
						 $("#UseDocPopupApproval").prop("checked",false);	
					 }

				    //팝업 공지 버튼 사용
					 if($("#UseDocPopupBtn").val()=="Y"){
						 $("#UseDocPopupBtn").prop("checked",true);	
					 }else{
						 $("#UseDocPopupBtn").prop("checked",false);	
					 }
					
					//일괄확인 사용
					 if($("#UseBlocCheck").val()=="Y"){
						 $("#UseBlocCheck").prop("checked",true);	
					 }else{
						 $("#UseBlocCheck").prop("checked",false);	
					 }
				    
					//일괄결재 사용
					 if($("#UseBlocApprove").val()=="Y"){
						 $("#UseBlocApprove").prop("checked",true);	
					 }else{
						 $("#UseBlocApprove").prop("checked",false);	
					 }
					
					//가로양식 사용
					 if($("#UseWideForm").val()=="Y"){
						 $("#UseWideForm").prop("checked",true);	
					 }else{
						 $("#UseWideForm").prop("checked",false);	
					 }

					 //외부연동 사용
					 if($("#UseOtherLegacyForm").val()=="Y"){
						 $("#UseOtherLegacyForm").prop("checked",true);	
					 }else{
						 $("#UseOtherLegacyForm").prop("checked",false);	
					 }
					
					 //문서수발신 담당자 사용
					 if($("#UseDeptReceiptManager").val()=="Y"){
						 $("#UseDeptReceiptManager").prop("checked",true);
					 }else{
						 $("#UseDeptReceiptManager").prop("checked",false);
					 }
					
				   //기밀문서 사용
					 if($("#UseApproveSecret").val()=="Y"){
						 $("#UseApproveSecret").prop("checked",true);	
					 }else{
						 $("#UseApproveSecret").prop("checked",false);	
					 }
				   
					//양식파일생성방법
					var vFormCreateKind = $("#FormCreateKind").val();
					
					if (paramFormID != "")  //수정모드
					{
					    if (mode == "SaveAs")
					        vFormCreateKind = "1";  //버젼업모드(SaveAs)일 경우 신규생성 모드로.. 
					    else
					        vFormCreateKind = "2";  //저장모드일경우에는 신규생성도 무조건 기존파일이용 모드로.. 
					}					
					if (vFormCreateKind == "1") {  //신규파일생성						
					    $('#rdoNewCreate').prop('checked', true);
					    ChangeFormCreateKind(1);
					 
					    if (mode == "SaveAs"){  //버젼업모드
					        $("#sourcefile").val($("#flnm").val());
					        $("#fmrv").val((gCurrVer*1)+1); // 현재버전에서 +1로 셋팅
					        MakeFormFileNm();
					    }
					}
					else if (vFormCreateKind == "2") {  //기존파일이용
					    $('#rdoOldFileUse').prop('checked', true);					    
					    ChangeFormCreateKind(2);					    
					    $("#UsingExistFile").val($("#flnm").val());
					    $("#flnm").val("");
					}
				   //결재알림사용 셋팅	
				   if(!axf.isEmpty($("#FmMailList").val()))
					{
			        var l_oldAuthList = $("#FmMailList").val().split('@');			       
			        if(l_oldAuthList.length>0){
				        var FmMailList = l_oldAuthList[0].split(';');	 
				        var l_checkedname = "";
				        if (FmMailList != "") {  
				        	for(var i = 0; i<FmMailList.length;i++){			        		
				        		$("input[name='chkMailauth']").each(function () {	    	
				        	        if ($(this).val()==FmMailList[i]) {
				        	            $(this).prop("checked", true);
				        	        }
				        	    });
				        	} 
				        }				       
			       	 }
					}
			        
				   
				   // 전결 리스트
				   ruleItemLists = ExtInfodata.RuleItemLists;
				}
				
		        //하위테이블구성 세싱
		        var jsonSubTableInfo = data.list[0].SubTableInfo;
		        		        	        
		       	var MainTableLength = (axf.isEmpty(jsonSubTableInfo.MainTable))? 0: jsonSubTableInfo.MainTable.length;
		       	var SubTable1Length = (axf.isEmpty(jsonSubTableInfo.SubTable1))? 0: jsonSubTableInfo.SubTable1.length;
		       	var SubTable2Length = (axf.isEmpty(jsonSubTableInfo.SubTable2))? 0: jsonSubTableInfo.SubTable2.length;
		       	var SubTable3Length = (axf.isEmpty(jsonSubTableInfo.SubTable3))? 0: jsonSubTableInfo.SubTable3.length;
		       	var SubTable4Length = (axf.isEmpty(jsonSubTableInfo.SubTable4))? 0: jsonSubTableInfo.SubTable4.length;
		         
		        for(var i = 0; i<MainTableLength; i++){		        	
		        	addSubTableFieldRow('SubMaster_FieldTable');	 
		        	$("#SubMaster_FieldTable tr#fmfield:eq("+i+")").find("input[name=FIELD_NAME]").val(jsonSubTableInfo.MainTable[i].FieldName);
		            $("#SubMaster_FieldTable tr#fmfield:eq("+i+")").find("input[name=FIELD_LABEL]").val(jsonSubTableInfo.MainTable[i].FieldLabel);
		            $("#SubMaster_FieldTable tr#fmfield:eq("+i+")").find("SELECT[name=FIELD_TYPE]").val(jsonSubTableInfo.MainTable[i].FieldType).prop("selected", true);		            
		            $("#SubMaster_FieldTable tr#fmfield:eq("+i+")").find("input[name=FIELD_LENGTH]").val(jsonSubTableInfo.MainTable[i].FieldLength);		            
		            $("#SubMaster_FieldTable tr#fmfield:eq("+i+")").find("input[name=FIELD_DEFAULT]").val(jsonSubTableInfo.MainTable[i].FieldDefault);
		            $("#SubMaster_FieldTable tr#fmfield:eq("+i+")").find("SELECT[name=OBJECT_TYPE]").val(jsonSubTableInfo.MainTable[i].ObjectType).prop("selected", true); 
		        }
		        for(var i = 0; i<SubTable1Length; i++){		        	
		        	addSubTableFieldRow('Sub_FieldTable1');	 
		        	$("#Sub_FieldTable1 tr#fmfield:eq("+i+")").find("input[name=FIELD_NAME]").val(jsonSubTableInfo.SubTable1[i].FieldName);
		            $("#Sub_FieldTable1 tr#fmfield:eq("+i+")").find("input[name=FIELD_LABEL]").val(jsonSubTableInfo.SubTable1[i].FieldLabel);
		            $("#Sub_FieldTable1 tr#fmfield:eq("+i+")").find("SELECT[name=FIELD_TYPE]").val(jsonSubTableInfo.SubTable1[i].FieldType).prop("selected", true);		            
		            $("#Sub_FieldTable1 tr#fmfield:eq("+i+")").find("input[name=FIELD_LENGTH]").val(jsonSubTableInfo.SubTable1[i].FieldLength);		            
		            $("#Sub_FieldTable1 tr#fmfield:eq("+i+")").find("input[name=FIELD_DEFAULT]").val(jsonSubTableInfo.SubTable1[i].FieldDefault);
		            $("#Sub_FieldTable1 tr#fmfield:eq("+i+")").find("SELECT[name=OBJECT_TYPE]").val(jsonSubTableInfo.SubTable1[i].ObjectType).prop("selected", true);
		        }
		        for(var i = 0; i<SubTable2Length; i++){		        	
		        	addSubTableFieldRow('Sub_FieldTable2');	 
		        	$("#Sub_FieldTable2 tr#fmfield:eq("+i+")").find("input[name=FIELD_NAME]").val(jsonSubTableInfo.SubTable2[i].FieldName);
		            $("#Sub_FieldTable2 tr#fmfield:eq("+i+")").find("input[name=FIELD_LABEL]").val(jsonSubTableInfo.SubTable2[i].FieldLabel);
		            $("#Sub_FieldTable2 tr#fmfield:eq("+i+")").find("SELECT[name=FIELD_TYPE]").val(jsonSubTableInfo.SubTable2[i].FieldType).prop("selected", true);		            
		            $("#Sub_FieldTable2 tr#fmfield:eq("+i+")").find("input[name=FIELD_LENGTH]").val(jsonSubTableInfo.SubTable2[i].FieldLength);		            
		            $("#Sub_FieldTable2 tr#fmfield:eq("+i+")").find("input[name=FIELD_DEFAULT]").val(jsonSubTableInfo.SubTable2[i].FieldDefault);
		            $("#Sub_FieldTable2 tr#fmfield:eq("+i+")").find("SELECT[name=OBJECT_TYPE]").val(jsonSubTableInfo.SubTable2[i].ObjectType).prop("selected", true);
		        }
		        for(var i = 0; i<SubTable3Length; i++){		        	
		        	addSubTableFieldRow('Sub_FieldTable3');	 
		        	$("#Sub_FieldTable3 tr#fmfield:eq("+i+")").find("input[name=FIELD_NAME]").val(jsonSubTableInfo.Sub_FieldTable3[i].FieldName);
		            $("#Sub_FieldTable3 tr#fmfield:eq("+i+")").find("input[name=FIELD_LABEL]").val(jsonSubTableInfo.SubTable3[i].FieldLabel);
		            $("#Sub_FieldTable3 tr#fmfield:eq("+i+")").find("SELECT[name=FIELD_TYPE]").val(jsonSubTableInfo.SubTable3[i].FieldType).prop("selected", true);
		            $("#Sub_FieldTable3 tr#fmfield:eq("+i+")").find("input[name=FIELD_LENGTH]").val(jsonSubTableInfo.SubTable3[i].FieldLength);		            
		            $("#Sub_FieldTable3 tr#fmfield:eq("+i+")").find("input[name=FIELD_DEFAULT]").val(jsonSubTableInfo.SubTable3[i].FieldDefault);
		            $("#Sub_FieldTable3 tr#fmfield:eq("+i+")").find("SELECT[name=OBJECT_TYPE]").val(jsonSubTableInfo.SubTable3[i].ObjectType).prop("selected", true);
		        }
		        for(var i = 0; i<SubTable4Length; i++){		        	
		        	addSubTableFieldRow('Sub_FieldTable4');	 
		        	$("#Sub_FieldTable4 tr#fmfield:eq("+i+")").find("input[name=FIELD_NAME]").val(jsonSubTableInfo.SubTable4[i].FieldName);
		            $("#Sub_FieldTable4 tr#fmfield:eq("+i+")").find("input[name=FIELD_LABEL]").val(jsonSubTableInfo.SubTable4[i].FieldLabel);
		            $("#Sub_FieldTable4 tr#fmfield:eq("+i+")").find("SELECT[name=FIELD_TYPE]").val(jsonSubTableInfo.SubTable4[i].FieldType).prop("selected", true);
		            $("#Sub_FieldTable4 tr#fmfield:eq("+i+")").find("input[name=FIELD_LENGTH]").val(jsonSubTableInfo.SubTable4[i].FieldLength);		            
		            $("#Sub_FieldTable4 tr#fmfield:eq("+i+")").find("input[name=FIELD_DEFAULT]").val(jsonSubTableInfo.SubTable4[i].FieldDefault);
		            $("#Sub_FieldTable4 tr#fmfield:eq("+i+")").find("SELECT[name=OBJECT_TYPE]").val(jsonSubTableInfo.SubTable4[i].ObjectType).prop("selected", true); 
		        }
		        
		        
		        //자동결재선 셋팅		        
		        var jsonAutoApprovalLine = data.list[0].AutoApprovalLine;
		        
		        if(!axf.isEmpty(jsonAutoApprovalLine)){		        
			       	
			        if(!axf.isEmpty(jsonAutoApprovalLine.CCAfter)){		       
				        //자동결재선 - 사후참조자 셋팅
				        if(jsonAutoApprovalLine.CCAfter.autoType=="R"){
				        	$("#ddCCAfter").prop("class","offOn");
				        	$("#CCAfterTree").hide();
							$("#CCAfterRegionTree").show();
				        }else{
				        	$("#ddCCAfter").prop("class","onOff");
				        	$("#CCAfterTree").show();
							$("#CCAfterRegionTree").hide();
				        }
				        if(jsonAutoApprovalLine.CCAfter.autoSet=="Y"){
				        	$("#UseDocAutoCcSet").prop("class","ckeckOn");		        	
				        }else{
				        	$("#UseDocAutoCcSet").prop("class","ckeckOff");
				        }
				        if(jsonAutoApprovalLine.CCAfter.autoChk=="Y"){
				        	$("#UseDocAutoCcChk").prop("class","ckeckOn");
				        }else{
				        	$("#UseDocAutoCcChk").prop("class","ckeckOff");
				        }
				        //자동결재선 - 사후참조자 - 계열사 셋팅
				        for(var i=0; i<TreeData.length; i++){
				        	
				        	if(!axf.isEmpty(jsonAutoApprovalLine.CCAfter.DocAutoApprovalEnt[TreeData[i].nodeValue])){					        	
					        	var DocAutoApprovalEntData = jsonAutoApprovalLine.CCAfter.DocAutoApprovalEnt[TreeData[i].nodeValue];					        	
					        			        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalEntData.item))? 0: DocAutoApprovalEntData.item.length;
					        	
					        	for(var j = 0; j<peopleLength;j++){
					        		
					        		var peopleData =(DocAutoApprovalEntData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "CCAfter"
							       
							        
							        var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeData[i].nodeValue+"\"); return false;'>삭제</a></span>";
								    $("#divCCAfter").find("#div"+TreeData[i].nodeValue).append(html);						        
					        		
					        	}
					        	if(DocAutoApprovalEntData.isUse=="Y"){				        		
					        		CCAfterTree.setCheckedObj("checkbox",TreeData[i].nodeValue,true);
					        	}
							}
				        }
				      	//자동결재선 - 사후참조자 - 사업장별 셋팅
				        for(var i=0; i<TreeDataRegion.length; i++){
				        	
				        	if(!axf.isEmpty(jsonAutoApprovalLine.CCAfter.DocAutoApprovalReg[TreeDataRegion[i].nodeValue])){
					        	var DocAutoApprovalRegData = jsonAutoApprovalLine.CCAfter.DocAutoApprovalReg[TreeDataRegion[i].nodeValue];
					        			        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalRegData.item))? 0: DocAutoApprovalRegData.item.length;
					        	
					        	for(var j = 0; j<peopleLength;j++){
					        		
					        		var peopleData =(DocAutoApprovalRegData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "CCAfter"
							       
						        	var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeDataRegion[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divCCAfter").find("#div"+TreeDataRegion[i].nodeValue).append(html);
					        	}
					        	if(DocAutoApprovalRegData.isUse=="Y"){
					        		CCAfterRegionTree.setCheckedObj("checkbox",TreeDataRegion[i].nodeValue,true);
					        	}
				        	}
				        }
					}
			        		        
			        if(!axf.isEmpty(jsonAutoApprovalLine.CCBefore)){
				      	//자동결재선 - 사전참조자 셋팅
			        	if(jsonAutoApprovalLine.CCBefore.autoType=="R"){
			        		$("#ddCCBefore").prop("class","offOn");
			        		$("#CCBeforeTree").hide();
			    			$("#CCBeforeRegionTree").show();
				        }else{
				        	$("#ddCCBefore").prop("class","onOff");							
				        	$("#CCBeforeTree").show();
							$("#CCBeforeRegionTree").hide();
				        }
				        if(jsonAutoApprovalLine.CCBefore.autoSet=="Y"){
				        	$("#UseDocAutoCcBeforeSet").prop("class","ckeckOn");		        	
				        }else{
				        	$("#UseDocAutoCcBeforeSet").prop("class","ckeckOff");
				        }
				        if(jsonAutoApprovalLine.CCBefore.autoChk=="Y"){
				        	$("#UseDocAutoCcBeforeChk").prop("class","ckeckOn");
				        }else{
				        	$("#UseDocAutoCcBeforeChk").prop("class","ckeckOff");
				        }
				        //자동결재선 - 사전참조자 - 계열사 셋팅
				        for(var i=0; i<TreeData.length; i++){
				        	
				        	if(!axf.isEmpty(jsonAutoApprovalLine.CCBefore.DocAutoApprovalEnt[TreeData[i].nodeValue])){
					        	var DocAutoApprovalEntData = jsonAutoApprovalLine.CCBefore.DocAutoApprovalEnt[TreeData[i].nodeValue];
					        	        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalEntData.item))? 0: DocAutoApprovalEntData.item.length;		        	
					        	
					        	for(var j = 0; j<peopleLength;j++){		        		
					        		var peopleData =(DocAutoApprovalEntData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "CCBefore"
							       
						        	var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeData[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divCCBefore").find("#div"+TreeData[i].nodeValue).append(html);
					        	}
					        	if(DocAutoApprovalEntData.isUse=="Y"){
					        		CCBeforeTree.setCheckedObj("checkbox",TreeData[i].nodeValue,true);
					        	}
				        	}
				        }
				        //자동결재선 - 사전참조자 - 사업장별 셋팅
				        for(var i=0; i<TreeDataRegion.length; i++){
				        	if(!axf.isEmpty(jsonAutoApprovalLine.CCBefore.DocAutoApprovalReg[TreeDataRegion[i].nodeValue])){
					        	var DocAutoApprovalRegData = jsonAutoApprovalLine.CCBefore.DocAutoApprovalReg[TreeDataRegion[i].nodeValue];					        	
					        			        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalRegData.item))? 0: DocAutoApprovalRegData.item.length;
					        	
					        	for(var j = 0; j<peopleLength;j++){
					        		
					        		var peopleData =(DocAutoApprovalRegData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "CCBefore"
							       
						        	var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeDataRegion[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divCCBefore").find("#div"+TreeDataRegion[i].nodeValue).append(html);
					        	}
					        	
					        	if(DocAutoApprovalRegData.isUse=="Y"){
					        		CCBeforeRegionTree.setCheckedObj("checkbox",TreeDataRegion[i].nodeValue,true);
					        	}
				        	}
				        }
			        }    
				        
				  if(!axf.isEmpty(jsonAutoApprovalLine.Approval)){
				      	//자동결재선 - 결재자 셋팅
					  	if(jsonAutoApprovalLine.Approval.autoType=="R"){
					  		$("#ddApproval").prop("class","offOn");
					  		$("#ApprovalTree").hide();
							$("#ApprovalRegionTree").show();
				        }else{
				        	$("#ddApproval").prop("class","onOff");
				        	$("#ApprovalTree").show();
							$("#ApprovalRegionTree").hide();
				        }
				        if(jsonAutoApprovalLine.Approval.autoSet=="Y"){
				        	$("#UseDocAutoApprovalSet").prop("class","ckeckOn");		        	
				        }else{
				        	$("#UseDocAutoApprovalSet").prop("class","ckeckOff");
				        }
				        if(jsonAutoApprovalLine.Approval.autoChk=="Y"){
				        	$("#UseDocAutoApprovalChk").prop("class","ckeckOn");
				        }else{
				        	$("#UseDocAutoApprovalChk").prop("class","ckeckOff");
				        }
				        //자동결재선 - 결재자 - 계열사 셋팅
				        for(var i=0; i<TreeData.length; i++){
				        	
				        	if(!axf.isEmpty(jsonAutoApprovalLine.Approval.DocAutoApprovalEnt[TreeData[i].nodeValue])){
					        	var DocAutoApprovalEntData = jsonAutoApprovalLine.Approval.DocAutoApprovalEnt[TreeData[i].nodeValue];
					        						        	        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalEntData.item))? 0: DocAutoApprovalEntData.item.length;		        	
					        	
					        	for(var j = 0; j<peopleLength;j++){		        		
					        		var peopleData =(DocAutoApprovalEntData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "Approval"
							       
						        	var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeData[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divApproval").find("#div"+TreeData[i].nodeValue).append(html);
					        	}
					        	
					        	if(DocAutoApprovalEntData.isUse=="Y"){
					        		ApprovalTree.setCheckedObj("checkbox",TreeData[i].nodeValue,true);
					        	}
				        	}
				        }
				        
				      //자동결재선 - 사전참조자 - 사업장별 셋팅
				        for(var i=0; i<TreeDataRegion.length; i++){
				        	if(!axf.isEmpty(jsonAutoApprovalLine.Approval.DocAutoApprovalReg[TreeDataRegion[i].nodeValue])){
					        	var DocAutoApprovalRegData = jsonAutoApprovalLine.Approval.DocAutoApprovalReg[TreeDataRegion[i].nodeValue];
					        					        			        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalRegData.item))? 0: DocAutoApprovalRegData.item.length;
					        					        	
					        	for(var j = 0; j<peopleLength;j++){
					        		
					        		var peopleData =(DocAutoApprovalRegData.item[j]);
					        		
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);						        
							        var LineKey = "Approval"
							        
						        	var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeDataRegion[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divApproval").find("#div"+TreeDataRegion[i].nodeValue).append(html);
					        	}
					        	if(DocAutoApprovalRegData.isUse=="Y"){
					        		ApprovalRegionTree.setCheckedObj("checkbox",TreeDataRegion[i].nodeValue,true);
					        	}
				        	}
				        }
			        }
				      
				        
				        
				       
			        if(!axf.isEmpty(jsonAutoApprovalLine.Agree)){
				      	//자동결재선 - 합의자 셋팅
			        	if(jsonAutoApprovalLine.Agree.autoType=="R"){
			        		$("#ddAgree").prop("class","offOn");
			        		$("#AgreeTree").hide();
			    			$("#AgreeRegionTree").show();
				        }else{
				        	$("#ddAgree").prop("class","onOff");
				        	$("#AgreeTree").show();
							$("#AgreeRegionTree").hide();
				        }
				        if(jsonAutoApprovalLine.Agree.autoSet=="Y"){
				        	$("#UseDocAutoAgreeSet").prop("class","ckeckOn");		        	
				        }else{
				        	$("#UseDocAutoAgreeSet").prop("class","ckeckOff");
				        }
				        if(jsonAutoApprovalLine.Agree.autoChk=="Y"){
				        	$("#UseDocAutoAgreeChk").prop("class","ckeckOn");
				        }else{
				        	$("#UseDocAutoAgreeChk").prop("class","ckeckOff");
				        }
				        //자동결재선 - 합의자 - 계열사 셋팅
				        for(var i=0; i<TreeData.length; i++){	
				        	if(!axf.isEmpty(jsonAutoApprovalLine.Agree.DocAutoApprovalEnt[TreeData[i].nodeValue])){
					        	var DocAutoApprovalEntData = jsonAutoApprovalLine.Agree.DocAutoApprovalEnt[TreeData[i].nodeValue];
					        	        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalEntData.item))? 0: DocAutoApprovalEntData.item.length;		        	
					        	
					        	
					        	for(var j = 0; j<peopleLength;j++){
					        		var peopleData =(DocAutoApprovalEntData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "Agree"
							       
						        	var html = "<span class='delBox' id='span"+sCode+"'><a onclick='toggleSerialCheckDiv(\"Agree\", \""+sCode+"\")'>"+sName+"</a><input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeData[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divAgree").find("#div"+TreeData[i].nodeValue).append(html);
					        	}
					        	if(DocAutoApprovalEntData.isUse=="Y"){
					        		AgreeTree.setCheckedObj("checkbox",TreeData[i].nodeValue,true);
					        	}
				        	}
				        }
				        //자동결재선 - 합의자 - 사업장별 셋팅
				        for(var i=0; i<TreeDataRegion.length; i++){
				        	if(!axf.isEmpty(jsonAutoApprovalLine.Agree.DocAutoApprovalReg[TreeDataRegion[i].nodeValue])){
					        	var DocAutoApprovalRegData = jsonAutoApprovalLine.Agree.DocAutoApprovalReg[TreeDataRegion[i].nodeValue];
					        					        			        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalRegData.item))? 0: DocAutoApprovalRegData.item.length;
					        	
					        	for(var j = 0; j<peopleLength;j++){
					        		
					        		var peopleData =(DocAutoApprovalRegData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "Agree"
							       
						        	var html = "<span class='delBox' id='span"+sCode+"'><a onclick='toggleSerialCheckDiv(\"Agree\", \""+sCode+"\")'>"+sName+"</a><input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeDataRegion[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divAgree").find("#div"+TreeDataRegion[i].nodeValue).append(html);
					        	}
					        	if(DocAutoApprovalRegData.isUse=="Y"){
					        		AgreeRegionTree.setCheckedObj("checkbox",TreeDataRegion[i].nodeValue,true);
					        	}
				        	}
				        }
			        }
			        			        
			        if(!axf.isEmpty(jsonAutoApprovalLine.Assist)){
				      	//자동결재선 - 협조자 셋팅
			        	if(jsonAutoApprovalLine.Assist.autoType=="R"){
			        		$("#ddAssist").prop("class","offOn");
			        		$("#AssistTree").hide();
			    			$("#AssistRegionTree").show();
				        }else{
				        	$("#ddAssist").prop("class","onOff");
				        	$("#AssistTree").show();
							$("#AssistRegionTree").hide();
				        }
				        if(jsonAutoApprovalLine.Assist.autoSet=="Y"){
				        	$("#UseDocAutoAssistSet").prop("class","ckeckOn");		        	
				        }else{
				        	$("#UseDocAutoAssistSet").prop("class","ckeckOff");
				        }
				        if(jsonAutoApprovalLine.Assist.autoChk=="Y"){
				        	$("#UseDocAutoAssistChk").prop("class","ckeckOn");
				        }else{
				        	$("#UseDocAutoAssistChk").prop("class","ckeckOff");
				        }
				        //자동결재선 - 협조자 - 계열사 셋팅
				        for(var i=0; i<TreeData.length; i++){	
				        	if(!axf.isEmpty(jsonAutoApprovalLine.Assist.DocAutoApprovalEnt[TreeData[i].nodeValue])){
					        	var DocAutoApprovalEntData = jsonAutoApprovalLine.Assist.DocAutoApprovalEnt[TreeData[i].nodeValue];
					        	        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalEntData.item))? 0: DocAutoApprovalEntData.item.length;		        	
					        	
					        	
					        	for(var j = 0; j<peopleLength;j++){
					        		var peopleData =(DocAutoApprovalEntData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "Assist"
							       
						        	var html = "<span class='delBox' id='span"+sCode+"'><a onclick='toggleSerialCheckDiv(\"Assist\", \""+sCode+"\")'>"+sName+"</a><input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeData[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divAssist").find("#div"+TreeData[i].nodeValue).append(html);
					        	}
					        	if(DocAutoApprovalEntData.isUse=="Y"){
					        		AssistTree.setCheckedObj("checkbox",TreeData[i].nodeValue,true);
					        	}
				        	}
				        }
				        //자동결재선 - 협조자 - 사업장별 셋팅
				        for(var i=0; i<TreeDataRegion.length; i++){
				        	if(!axf.isEmpty(jsonAutoApprovalLine.Assist.DocAutoApprovalReg[TreeDataRegion[i].nodeValue])){
					        	var DocAutoApprovalRegData = jsonAutoApprovalLine.Assist.DocAutoApprovalReg[TreeDataRegion[i].nodeValue];
					        					        			        	
					        	var peopleLength = (axf.isEmpty(DocAutoApprovalRegData.item))? 0: DocAutoApprovalRegData.item.length;
					        	
					        	for(var j = 0; j<peopleLength;j++){
					        		
					        		var peopleData =(DocAutoApprovalRegData.item[j]);
					        		var sCode = peopleData.AN;	
							        var sName = CFN_GetDicInfo(peopleData.DN);
							        var LineKey = "Assist"
							       
						        	var html = "<span class='delBox' id='span"+sCode+"'><a onclick='toggleSerialCheckDiv(\"Assist\", \""+sCode+"\")'>"+sName+"</a><input type='hidden' id='ipt"+sCode+"' value='"+JSON.stringify(peopleData)+"'>"
								    html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+LineKey+"\",\""+TreeDataRegion[i].nodeValue+"\"); return false;'>삭제</a></span>";				       
							        $("#divAssist").find("#div"+TreeDataRegion[i].nodeValue).append(html);
					        	}
					        	if(DocAutoApprovalRegData.isUse=="Y"){
					        		AssistRegionTree.setCheckedObj("checkbox",TreeDataRegion[i].nodeValue,true);
					        	}
				        	}
				        }
			        }
		       	 }
		       
		        
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getAdminFormData.do", response, status, error);
			}
		});
	}
	
	// 저장버튼 클릭
	function btnSave_Click(){
		//if ($("#fmpf").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_012' />"); return false; } //"양식키(영문)을 입력하십시오."
		var bAutoForm = false;
		if ($("#fmpf").val() == ""){
			bAutoForm = true;
		}
		//if ($("#fmnm").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_011' />"); return false; }  //  "양식명(한글)을 입력하십시오."
		if ($("#ko_full").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_011' />"); return false; }  //  "양식명(한글)을 입력하십시오."
		if ($("#selclass").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_516' />"); return false; }  //  "양식분류를 선택해주세요"
		if ($("#selschema").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_517' />"); return false; }  //  "양식프로세스를 선택해주세요"
		
		//if ($("#SubTableSPName").val() == "" && $("#MainTable").val() != "") { parent.Common.Warning("<spring:message code='Cache.msg_apv_Inputsub1' />")); return false; }  //  "하위테이블 SP명을 입력하십시오."
		//if ($("#SubTableSPName").val() != "" && $("#MainTable").val() == "") { parent.Common.Warning("<spring:message code='Cache.msg_apv_Inputsub2' />")); return false; }  //  "하위마스터테이블을 입력하십시오."

		if ($("#fmsk").val() == "") { $("#fmsk").val("0"); }
		else { if (!isNaN($("#fmsk").val()) == false) { Common.Warning("<spring:message code='Cache.msg_apv_013' />"); return false; } }  //  "정렬값은 숫자로 입력하십시오."

		if ($("#fmrv").val() == "") { $("#fmrv").val("0"); }
		else { if (!isNaN($("#fmrv").val()) == false) { Common.Warning("<spring:message code='Cache.msg_apv_014' />"); return false; } } //  "버전은 숫자로 입력하십시오."

		if ($("#FormCreateKind").val() == "2") {  //기존파일이용
            if ($("#UsingExistFile").val() == "") {
            	Common.Warning("<spring:message code='Cache.lbl_SelUsingExistFile' />");  //이용할 기존파일을 선택하세요
                clickTab("[value='divFormHtmlnfo']");
                //ChangeFormCreateKind(2);
                $("#UsingExistFile").focus();
                return false;
            }
        }
		
		if($("#MobileFormYN").is(":checked") && $("#UseMultiEditYN").is(":checked")) {
			Common.Warning("<spring:message code='Cache.msg_apv_MobileMultiDraftNotAllow' />");  //다안기안 설정 시 모바일 양식은 설정이 불가합니다.
            return false;
		}
		
		var isCheckDup = true;
		if (mode == "SaveAs") {
            if (gCurrVer == $("#fmrv").val()) {
                //ChangeTab("divFormBasicInfo");
                $("#fmrv").focus();
                Common.Warning("<spring:message code='Cache.lbl_DiffCurVer' />"); //현재버젼과 달라야 합니다!
                return;
            }
		 }else if(mode == "add"){								//중복 체크 했는지 확인
			 $("a[id^=IsUse]").each(function(){
				 if($(this).attr("class") == "chkeckSubTableOn"){
					 $(this).parent().parent().find("input[id^=isCheckDup]").each(function(i,obj){
						 if($(obj).val() == "N"){
							Common.Warning("<spring:message code='Cache.msg_addFormTableDupCheck' />");
							isCheckDup =  false;
							
							return false;
						 }
					 });
				 }
			 });
		 
		 	if(!isCheckDup) {
		 		// 하위테이블 validation
				$("#divSubTableSetting").find("input[type=text]").each(function (i, obj) {
					if ($(obj).attr("id") == "FIELD_NAME" && $(obj).val() == "") {
						Common.Warning("<spring:message code='Cache.msg_apv_355' />"); // 필드ID를 영어로 입력하십시오.
						$(obj).focus();
						return;
					}
					else if ($(obj).attr("id") == "FIELD_LABEL" && $(obj).val() == "") {
						Common.Warning("<spring:message code='Cache.msg_EnterFieldNm' />");  // 필드명을 입력하십시오.
						$(obj).focus();
						return;
					}
					else if ($(obj).attr("id") == "FIELD_TYPE" && $(obj).val() == "") {
						Common.Warning("<spring:message code='Cache.msg_apv_015' />");  // 필드 길이는 숫자로 입력하십시오.
						$(obj).focus();
						return;
					}
				});		
		 	}
		 	
		 	//formprefix 및 버전 중복 확인
		 	if(!bAutoForm){
			 	$.ajax({
					url:"addFormDuplicateCheck.do",
					type:"post",
					data: {
						"Formprefix" : $("#fmpf").val(),
						"Revision" : $("#fmrv").val(),
						"CompanyCode" : $("#selectCompanyCode").val(),
						"isSaaS" : '${strisSaaS}' 
						},
					async:false,
					success:function (data) {
						if(!data.result){
							isCheckDup =  false;
							Common.Warning("<spring:message code='Cache._msg_FormDuplicate' />"); //양식키가 중복되었습니다. 양식키 및 버전을 확인해주세요.
							return false;
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("addFormDuplicateCheck.do", response, status, error);
					}
				});
		 	}
		 }
		
		if(isCheckDup)
			saveForm();
	}
	
	// 양식 데이터 추가 및 저장
	function saveForm(){

		//var dextHtmlValue = DEXT5.getBodyValue(gx_id);
		var dextHtmlValue = "";
		var dextInlineImage = "";
		var dextBackgroundImage = "";
		
		try{
			if(g_isLoadEditor){
				dextHtmlValue = coviEditor.getBody(g_editorKind, g_id);
				dextInlineImage = coviEditor.getImages(g_editorKind, g_id);
				dextBackgroundImage = coviEditor.getBackgroundImage(g_editorKind, g_id);
			}else{
				dextHtmlValue = $("#hidBodyDefault").val();
			}
		}catch(e){console.log(e);}
		
		//신규파일생성이든 기존파일이용이든 파일명은 flnm필드에 대입 (2012-04-02 HIW)
	    //(어느경우든 WF_FORMS테이블의 FILE_NAME필드에 파일명을 넣기위함)
	    if ($("#FormCreateKind").val() == "2")
	        $("#flnm").val($("#UsingExistFile").val());
		
	 	// 통합 양식 사용 유무 (2014-04-28 leesh)
	    if ($('#UnifiedFormYN').is(':checked'))
	        $("#UnifiedFormYN").val("Y");
	    else
	        $("#UnifiedFormYN").val("N");

	 	// 모바일 양식 여부 (2018-06-01 deryu)
	    if ($('#MobileFormYN').is(':checked'))
	        $("#MobileFormYN").val("Y");
	    else
	        $("#MobileFormYN").val("N");
	 	
	    //다안기안 여부
	    if ($('#UseMultiEditYN').is(':checked'))
	        $("#UseMultiEditYN").val("Y");
	    else
	        $("#UseMultiEditYN").val("N");	
	 	
	  	//웹에디터사용유무
	    if ($('#UseEditYN').is(':checked'))
	        $("#UseEditYN").val("Y");
	    else
	        $("#UseEditYN").val("N");

	    //HWP Active X 사용유무 //20180411
	    if ($('#UseHWPEditYN').is(':checked'))
	        $("#UseHWPEditYN").val("Y");
	    else
	        $("#UseHWPEditYN").val("N");
	    
	    //웹한글기안기 사용유무 //20180411
	    if ($('#UseWebHWPEditYN').is(':checked'))
	        $("#UseWebHWPEditYN").val("Y");
	    else
	        $("#UseWebHWPEditYN").val("N");
	    
	  //일괄확인 사용 유무
	    if ($('#UseBlocCheck').is(':checked'))
	        $("#UseBlocCheck").val("Y");
	    else
	        $("#UseBlocCheck").val("N");
	    
	    //일괄결재 사용 유무
	    if ($('#UseBlocApprove').is(':checked'))
	        $("#UseBlocApprove").val("Y");
	    else
	        $("#UseBlocApprove").val("N");
	    
	  	//가로양식 사용 유무
	    if ($('#UseWideForm').is(':checked'))
	        $("#UseWideForm").val("Y");
	    else
	        $("#UseWideForm").val("N");

	  	//외부연동 사용 유무
	    if ($('#UseOtherLegacyForm').is(':checked'))
	        $("#UseOtherLegacyForm").val("Y");
	    else
	        $("#UseOtherLegacyForm").val("N");
	  	
	  	//문서수발신 담당자 사용 유무
	  	if($('#UseDeptReceiptManager').is(':checked'))
	  		$("#UseDeptReceiptManager").val("Y");
	  	else
	  		$("#UseDeptReceiptManager").val("N");
	  	
	    //기밀문서 사용 유무
	    if ($('#UseApproveSecret').is(':checked'))
	        $("#UseApproveSecret").val("Y");
	    else
	        $("#UseApproveSecret").val("N");
	  	
	    //양식 도움말 사용 유무
	    if ($('#UseDocHelpApproval').is(':checked'))
	        $("#UseDocHelpApproval").val("Y");
	    else
	        $("#UseDocHelpApproval").val("N");

	    //팝업 공지 사용 자동 유무
	    if ($('#UseDocPopupApproval').is(':checked'))
	        $("#UseDocPopupApproval").val("Y");
	    else
	        $("#UseDocPopupApproval").val("N");

	    //팝업 공지 사용 버튼 유무
	    if ($('#UseDocPopupBtn').is(':checked'))
	        $("#UseDocPopupBtn").val("Y");
	    else
	        $("#UseDocPopupBtn").val("N");
	  	
	  	
		
		var FormClassID = $("#selclass").val();
		var SchemaID = $("#selschema").val();
		var IsUse = $("#fmst").val();
		var Revision = $("#fmrv").val();
		var SortKey = $("#fmsk").val();
		//var FormName = $("#fmnm").val();
		var FormName = $("#ko_full").val() + ";" + $("#en_full").val() + ";" + $("#ja_full").val() + ";" + $("#zh_full").val();
		var FormPrefix = $("#fmpf").val();
		var FormDesc = $("#fmds").val();
		var sourcefile = $("#sourcefile").val();
		var FileName = $("#flnm").val();
		//var BodyDefault = $("#divWebEditor").val();
		var BodyDefault = dextHtmlValue;
		var BodyDefaultInlineImage = dextInlineImage;
		var BodyBackgroundImage = dextBackgroundImage;
		var EntCode = ";" + $("#selectCompanyCode").val();
		var ExtInfo = "";	
		var AutoApprovalLine = "";
		var BodyType = $("#fmbt").val();
		var SubTableInfo ="";
		var IsEditFormHelper = $("#IsDocHelpApprovalEdit").val();
		var FormHelperContext = $("#DocHelpApproval").val();
		var FormHelperImages = $("#DocHelpApprovalImages").val();
		var IsEditFormNotice = $("#IsDocPopupApprovalEdit").val();
		var FormNoticeContext = $("#DocPopupApproval").val();
		var FormNoticeImages = $("#DocPopupApprovalImages").val();
		var CompanyCode = $("#selectCompanyCode").val();
		var FormIcon = $(".form_icon_selector input[name=icon]:checked").parent().attr("data-type");
		if (OrgFileEntCode == "" || OrgFileEntCode == null) OrgFileEntCode = $("#selectCompanyCode").val();
		if (FileName == "" || !FileName) { MakeFormFileNm(); FileName = $("#flnm").val(); }
		
		// 권한.
		var AclAllYN = "Y";
		var userAclAllYn = $("[name=AclAllYN]:checked").val(); // radio box
		if("Y" == userAclAllYn){
			parent._setParamdataAuth = {};
			AclAllYN = userAclAllYn;
		}
		var AuthDept = JSON.stringify(parent._setParamdataAuth); // Reserved1
		if (parent._setParamdataAuth.hasOwnProperty('item') && parent._setParamdataAuth.item.length > 0){ AclAllYN = "N"; }
		
		//var Reserved2 = $("#").val();
		//var Reserved3 = $("#").val();
		//var Reserved4 = $("#").val();
		//var Reserved5 = $("#").val();
		
		
		//ExtInfo JSONobject 생성			
		jQuery.ajaxSettings.traditional = true;
		
		var ExtInfoObj = new Object();
			
		ExtInfoObj.FormCreateKind = $("#FormCreateKind").val();
		ExtInfoObj.SecurityGrade = $("#SecurityGrade").val();
		ExtInfoObj.DocClassName = $("#DocClassName").val();
		ExtInfoObj.DocClassID = $("#DocClassID").val();
		ExtInfoObj.EntDocClassID = $("#EntDocClassID").val();
		ExtInfoObj.PreservPeriod = $("#PreservPeriod").val();
		ExtInfoObj.UnifiedFormYN = $("#UnifiedFormYN").val();
		ExtInfoObj.MobileFormYN = $("#MobileFormYN").val();
		ExtInfoObj.UseMultiEditYN = $("#UseMultiEditYN").val();
		ExtInfoObj.UseEditYN = $("#UseEditYN").val();
		ExtInfoObj.UseHWPEditYN = $("#UseHWPEditYN").val(); //20180411
		ExtInfoObj.UseWebHWPEditYN = $("#UseWebHWPEditYN").val(); //20200806
		ExtInfoObj.UseBlocCheck = $("#UseBlocCheck").val();
		ExtInfoObj.UseBlocApprove = $("#UseBlocApprove").val();
		ExtInfoObj.UseWideForm = $("#UseWideForm").val();
		ExtInfoObj.UseOtherLegacyForm = $("#UseOtherLegacyForm").val();
		ExtInfoObj.UseDeptReceiptManager = $("#UseDeptReceiptManager").val(); //20200821
		ExtInfoObj.UseApproveSecret = $("#UseApproveSecret").val();
		ExtInfoObj.FmMailList = $("#FmMailList").val();
		ExtInfoObj.UseDocHelpApproval = $("#UseDocHelpApproval").val();
		ExtInfoObj.UseDocPopupApproval = $("#UseDocPopupApproval").val();
		ExtInfoObj.UseDocPopupBtn = $("#UseDocPopupBtn").val();
		ExtInfoObj.TxtViewReport = $("#TxtViewReport").val();
		ExtInfoObj.HiddenViewReport = $("#HiddenViewReport").val();
		ExtInfoObj.MainTable = $("#MainTable").val();
		ExtInfoObj.SubTable1 = $("#SubTable1").val();
		ExtInfoObj.SubSort1 = $("#SubSort1").val();
		ExtInfoObj.SubTable2 = $("#SubTable2").val();
		ExtInfoObj.SubSort2 = $("#SubSort2").val();
		ExtInfoObj.SubTable3 = $("#SubTable3").val();
		ExtInfoObj.SubSort3 = $("#SubSort3").val();
		ExtInfoObj.SubTable4 = $("#SubTable4").val();
		ExtInfoObj.SubSort4 = $("#SubSort4").val();
		
		
		// 전결 선택 리스트
		var objArr = new Array();
		$('#ruleItemDiv :checked').each(function() {
			var entCode = $(this).val().split(',')[0];
			var itemId = $(this).val().split(',')[1];
			var obj = new Object();
			var tempObjArr = new Array();
			var len = objArr.length;
			
			if (len > 0) {
				for (var i=0; i<len; i++) {
					if (entCode == objArr[i].DNCode) {
						objArr[i].ruleitem.push(itemId);
					} else {
						if (i == len-1) {
							obj.DNCode = entCode;
							tempObjArr.push(itemId);
							obj.ruleitem = tempObjArr;
							objArr.push(obj);
							break;
						}
					}
				}
			} else {
				obj.DNCode = entCode;
				tempObjArr.push(itemId);
				obj.ruleitem = tempObjArr;
				objArr.push(obj);
			}
		});
		ExtInfoObj.RuleItemLists = objArr;
		
		
		//jsavaScript 객체를 JSON 객체로 변환
		ExtInfo = JSON.stringify(ExtInfoObj)
		
		
		//AutoApprovalLine JSONobject 생성	
		
		// 이전 셋팅값 (타 계열사 설정 유지하기 위해)
		var oldJsonAutoApprovalLine;
		if(gOldData && gOldData.list && gOldData.list.length > 0 && gOldData.list[0].AutoApprovalLine) oldJsonAutoApprovalLine = gOldData.list[0].AutoApprovalLine;
		
		//사후참조자세팅
		var CCAfterObj = new Object();
		var CCAfterCheckedTree = CCAfterTree.getCheckedTreeList("checkbox");
					
		
		for(var i = 0; i<TreeData.length; i++){
			var nodeValue = TreeData[i].nodeValue;			
			var CCAfterArray = new Array();		
			$("#divCCAfter").find("#div"+nodeValue).find("input[type='hidden']").each(function(){
				CCAfterArray.push(jQuery.parseJSON($(this).val()));
			});
			
			var CCAfterTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<CCAfterCheckedTree.length; j++){				
				if(TreeData[i].nodeValue==CCAfterCheckedTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(CCAfterTree.list, TreeData[i].nodeValue, oldJsonAutoApprovalLine, "CCAfter", "DocAutoApprovalEnt");
			
			CCAfterTreeObj["isUse"] = isUseYN;			
			CCAfterTreeObj.item = CCAfterArray;				
			CCAfterObj[nodeValue] = CCAfterTreeObj;
		}
		
		var CCAfterRegionTObj = new Object();
		var CCAfterCheckedRegionTree = CCAfterRegionTree.getCheckedTreeList("checkbox");
		for(var i = 0; i<TreeDataRegion.length; i++){
			var nodeValue = TreeDataRegion[i].nodeValue;
			
			var CCAfterArray = new Array();		
			
			
			$("#divCCAfter").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){	
				CCAfterArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var CCAfterTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<CCAfterCheckedRegionTree.length; j++){				
				if(TreeDataRegion[i].nodeValue==CCAfterCheckedRegionTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(CCAfterRegionTree.list, TreeDataRegion[i].nodeValue, oldJsonAutoApprovalLine, "CCAfter", "DocAutoApprovalReg");
			
			CCAfterTreeObj["isUse"] = isUseYN;			
			CCAfterTreeObj.item = CCAfterArray;				
			CCAfterRegionTObj[nodeValue] = CCAfterTreeObj;
		}
		
		var CCAfter = new Object();
		
		CCAfter.autoType = ($("#ddCCAfter").attr("class")=="onOff") ? "E" : "R";
		CCAfter.autoSet = ($("#UseDocAutoCcSet").attr("class")=="ckeckOn") ? "Y" : "N";
		CCAfter.autoChk = ($("#UseDocAutoCcChk").attr("class")=="ckeckOn") ? "Y" : "N";
		CCAfter.DocAutoApprovalEnt = CCAfterObj;
		CCAfter.DocAutoApprovalReg = CCAfterRegionTObj;
		
	
		//사전참조자세팅
		var CCBeforeObj = new Object();
		var CCBeforeCheckedTree = CCBeforeTree.getCheckedTreeList("checkbox");
					
		
		for(var i = 0; i<TreeData.length; i++){
			var nodeValue = TreeData[i].nodeValue;
			
			var CCBeforeArray = new Array();		
			$("#divCCBefore").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){				
				CCBeforeArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var CCBeforeTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<CCBeforeCheckedTree.length; j++){				
				if(TreeData[i].nodeValue==CCBeforeCheckedTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(CCBeforeTree.list, TreeData[i].nodeValue, oldJsonAutoApprovalLine, "CCBefore", "DocAutoApprovalEnt");
			
			CCBeforeTreeObj["isUse"] = isUseYN;			
			CCBeforeTreeObj.item = CCBeforeArray;				
			CCBeforeObj[nodeValue] = CCBeforeTreeObj;
		}
	
		
		var CCBeforeRegionTObj = new Object();
		var CCBeforeCheckedRegionTree = CCBeforeRegionTree.getCheckedTreeList("checkbox");
		for(var i = 0; i<TreeDataRegion.length; i++){
			var nodeValue = TreeDataRegion[i].nodeValue;
			
			var CCBeforeArray = new Array();		
			$("#divCCBefore").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){				
					CCBeforeArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var CCBeforeTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<CCBeforeCheckedRegionTree.length; j++){				
				if(TreeDataRegion[i].nodeValue==CCBeforeCheckedRegionTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(CCBeforeRegionTree.list, TreeDataRegion[i].nodeValue, oldJsonAutoApprovalLine, "CCBefore", "DocAutoApprovalReg");
			
			CCBeforeTreeObj["isUse"] = isUseYN;			
			CCBeforeTreeObj.item = CCBeforeArray;				
			CCBeforeRegionTObj[nodeValue] = CCBeforeTreeObj;
		}
		
		
		var CCBefore = new Object();
		
		CCBefore.autoType = ($("#ddCCBefore").attr("class")=="onOff") ? "E" : "R";
		CCBefore.autoSet = ($("#UseDocAutoCcBeforeSet").attr("class")=="ckeckOn") ? "Y" : "N";
		CCBefore.autoChk = ($("#UseDocAutoCcBeforeChk").attr("class")=="ckeckOn") ? "Y" : "N";
		CCBefore.DocAutoApprovalEnt = CCBeforeObj;
		CCBefore.DocAutoApprovalReg = CCBeforeRegionTObj;
		
		
		//결재자세팅
		var ApprovalObj = new Object();
		var ApprovalCheckedTree = ApprovalTree.getCheckedTreeList("checkbox");
					
		
		for(var i = 0; i<TreeData.length; i++){
			var nodeValue = TreeData[i].nodeValue;
			
			var ApprovalArray = new Array();		
			$("#divApproval").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){				
				ApprovalArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var ApprovalTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<ApprovalCheckedTree.length; j++){				
				if(TreeData[i].nodeValue==ApprovalCheckedTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(ApprovalTree.list, TreeData[i].nodeValue, oldJsonAutoApprovalLine, "Approval", "DocAutoApprovalEnt");
			
			ApprovalTreeObj["isUse"] = isUseYN;			
			ApprovalTreeObj.item = ApprovalArray;				
			ApprovalObj[nodeValue] = ApprovalTreeObj;
		}
	
		
		var ApprovalRegionTObj = new Object();
		var ApprovalCheckedRegionTree = ApprovalRegionTree.getCheckedTreeList("checkbox");
		for(var i = 0; i<TreeDataRegion.length; i++){
			var nodeValue = TreeDataRegion[i].nodeValue;
			
			var ApprovalArray = new Array();		
			$("#divApproval").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){				
					ApprovalArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var ApprovalTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<ApprovalCheckedRegionTree.length; j++){				
				if(TreeDataRegion[i].nodeValue==ApprovalCheckedRegionTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(ApprovalRegionTree.list, TreeDataRegion[i].nodeValue, oldJsonAutoApprovalLine, "Approval", "DocAutoApprovalReg");
			
			ApprovalTreeObj["isUse"] = isUseYN;			
			ApprovalTreeObj.item = ApprovalArray;				
			ApprovalRegionTObj[nodeValue] = ApprovalTreeObj;
		}
		
		var Approval = new Object();
		
		Approval.autoType = ($("#ddApproval").attr("class")=="onOff") ? "E" : "R";
		Approval.autoSet = ($("#UseDocAutoApprovalSet").attr("class")=="ckeckOn") ? "Y" : "N";
		Approval.autoChk = ($("#UseDocAutoApprovalChk").attr("class")=="ckeckOn") ? "Y" : "N";
		Approval.DocAutoApprovalEnt = ApprovalObj;
		Approval.DocAutoApprovalReg = ApprovalRegionTObj;
		
		
		//합의자세팅
		var AgreeObj = new Object();
		var AgreeCheckedTree = AgreeTree.getCheckedTreeList("checkbox");
					
		
		for(var i = 0; i<TreeData.length; i++){
			var nodeValue = TreeData[i].nodeValue;
			
			var AgreeArray = new Array();		
			$("#divAgree").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){				
				AgreeArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var AgreeTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<AgreeCheckedTree.length; j++){				
				if(TreeData[i].nodeValue==AgreeCheckedTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(AgreeTree.list, TreeData[i].nodeValue, oldJsonAutoApprovalLine, "Agree", "DocAutoApprovalEnt");
			
			AgreeTreeObj["isUse"] = isUseYN;			
			AgreeTreeObj.item = AgreeArray;				
			AgreeObj[nodeValue] = AgreeTreeObj;
		}
	
		var AgreeRegionTObj = new Object();
		var AgreeCheckedRegionTree = AgreeRegionTree.getCheckedTreeList("checkbox");
		for(var i = 0; i<TreeDataRegion.length; i++){
			var nodeValue = TreeDataRegion[i].nodeValue;
			
			var AgreeArray = new Array();		
			$("#divAgree").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){				
					AgreeArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var AgreeTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<AgreeCheckedRegionTree.length; j++){				
				if(TreeDataRegion[i].nodeValue==AgreeCheckedRegionTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(AgreeRegionTree.list, TreeDataRegion[i].nodeValue, oldJsonAutoApprovalLine, "Agree", "DocAutoApprovalReg");
			
			AgreeTreeObj["isUse"] = isUseYN;			
			AgreeTreeObj.item = AgreeArray;				
			AgreeRegionTObj[nodeValue] = AgreeTreeObj;
		}
		
		var Agree = new Object();
		
		Agree.autoType = ($("#ddAgree").attr("class")=="onOff") ? "E" : "R";
		Agree.autoSet = ($("#UseDocAutoAgreeSet").attr("class")=="ckeckOn") ? "Y" : "N";
		Agree.autoChk = ($("#UseDocAutoAgreeChk").attr("class")=="ckeckOn") ? "Y" : "N";
		Agree.DocAutoApprovalEnt = AgreeObj;
		Agree.DocAutoApprovalReg = AgreeRegionTObj;
		
		
		
		//협조자세팅
		var AssistObj = new Object();
		var AssistCheckedTree = AssistTree.getCheckedTreeList("checkbox");
					
		
		for(var i = 0; i<TreeData.length; i++){
			var nodeValue = TreeData[i].nodeValue;
			
			var AssistArray = new Array();		
			$("#divAssist").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){				
				AssistArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var AssistTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<AssistCheckedTree.length; j++){				
				if(TreeData[i].nodeValue==AssistCheckedTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(AssistTree.list, TreeData[i].nodeValue, oldJsonAutoApprovalLine, "Assist", "DocAutoApprovalEnt");
			
			AssistTreeObj["isUse"] = isUseYN;			
			AssistTreeObj.item = AssistArray;				
			AssistObj[nodeValue] = AssistTreeObj;
		}
	
		var AssistRegionTObj = new Object();
		var AssistCheckedRegionTree = AssistRegionTree.getCheckedTreeList("checkbox");
		for(var i = 0; i<TreeDataRegion.length; i++){
			var nodeValue = TreeDataRegion[i].nodeValue;
			
			var AssistArray = new Array();		
			$("#divAssist").find("#div"+nodeValue).find("input[type='hidden']").each(function(i){				
					AssistArray.push(jQuery.parseJSON($(this).val()));		
										
			});
			
			var AssistTreeObj = new Object();
			
			var isUseYN = "N";
			for(var j=0; j<AssistCheckedRegionTree.length; j++){				
				if(TreeDataRegion[i].nodeValue==AssistCheckedRegionTree[j].nodeValue){
					isUseYN = "Y";					
					break;
				}
			}
			// 권한없는 계열사는 이전 설정값 유지(체크박스)
			if(isUseYN == "N") isUseYN = getOldApvOptionYN(AssistRegionTree.list, TreeDataRegion[i].nodeValue, oldJsonAutoApprovalLine, "Assist", "DocAutoApprovalReg");
			
			AssistTreeObj["isUse"] = isUseYN;			
			AssistTreeObj.item = AssistArray;				
			AssistRegionTObj[nodeValue] = AssistTreeObj;
		}
		
		var Assist = new Object();
		
		Assist.autoType = ($("#ddAssist").attr("class")=="onOff") ? "E" : "R";
		Assist.autoSet = ($("#UseDocAutoAssistSet").attr("class")=="ckeckOn") ? "Y" : "N";
		Assist.autoChk = ($("#UseDocAutoAssistChk").attr("class")=="ckeckOn") ? "Y" : "N";
		Assist.DocAutoApprovalEnt = AssistObj;
		Assist.DocAutoApprovalReg = AssistRegionTObj;
		
		
		
		//결재선 셋팅
		var AutoApprovalLineObj = new Object();
				 
		//jsavaScript 객체를 JSON 객체로 변환
		AutoApprovalLineObj.CCAfter = CCAfter;
		AutoApprovalLineObj.CCBefore = CCBefore;
		AutoApprovalLineObj.Approval = Approval;
		AutoApprovalLineObj.Agree = Agree;
		AutoApprovalLineObj.Assist = Assist;
		
		
		AutoApprovalLine = JSON.stringify(AutoApprovalLineObj);
		
		
		
		//SubTableInfo JSONobject 생성
		var SubTableInfoObj = new Object();
		
		var MainTableArray = new Array();		
		jQuery.ajaxSettings.traditional = true;
		
		$("#SubMaster_FieldTable tr:not(:first)").each(function(i){
			var MainTableObj = new Object();
			MainTableObj.FieldName = $(this).find("input#FIELD_NAME").val();
			MainTableObj.FieldLabel = $(this).find("input#FIELD_LABEL").val();
			MainTableObj.FieldType = $(this).find("SELECT#FIELD_TYPE").val() == null ? "" : $(this).find("SELECT#FIELD_TYPE").val();
			MainTableObj.FieldLength = $(this).find("input#FIELD_LENGTH").val();
			MainTableObj.FieldDefault = $(this).find("input#FIELD_DEFAULT").val();
			MainTableObj.ObjectType = $(this).find("SELECT#OBJECT_TYPE").val() == null ? "" : $(this).find("SELECT#OBJECT_TYPE").val();		
						
			MainTableArray.push(MainTableObj);			
		});		
			
		if(MainTableArray.length > 0){
			SubTableInfoObj.MainTable = MainTableArray;
		}
	
		
		
		var SubTable1Array = new Array();		
		jQuery.ajaxSettings.traditional = true;
		$("#Sub_FieldTable1 tr:not(:first)").each(function(i){
			var SubTable1Obj = new Object();
			
			SubTable1Obj.FieldName = $(this).find("input#FIELD_NAME").val();
			SubTable1Obj.FieldLabel = $(this).find("input#FIELD_LABEL").val();
			SubTable1Obj.FieldType = $(this).find("SELECT#FIELD_TYPE").val() == null ? "" : $(this).find("SELECT#FIELD_TYPE").val();
			SubTable1Obj.FieldLength = $(this).find("input#FIELD_LENGTH").val();
			SubTable1Obj.FieldDefault = $(this).find("input#FIELD_DEFAULT").val(); 
			SubTable1Obj.ObjectType = $(this).find("SELECT#OBJECT_TYPE").val() == null ? "" : $(this).find("SELECT#OBJECT_TYPE").val();
						
			SubTable1Array.push(SubTable1Obj);			
		});	
					
		if(SubTable1Array.length > 0){
			SubTableInfoObj.SubTable1 = SubTable1Array;
		}
		
		var SubTable2Array = new Array();		
		jQuery.ajaxSettings.traditional = true;
		$("#Sub_FieldTable2 tr:not(:first)").each(function(i){
			var SubTable2Obj = new Object();
			
			SubTable2Obj.FieldName = $(this).find("input#FIELD_NAME").val();
			SubTable2Obj.FieldLabel = $(this).find("input#FIELD_LABEL").val();
			SubTable2Obj.FieldType = $(this).find("SELECT#FIELD_TYPE").val() == null ? "" : $(this).find("SELECT#FIELD_TYPE").val();
			SubTable2Obj.FieldLength = $(this).find("input#FIELD_LENGTH").val();
			SubTable2Obj.FieldDefault = $(this).find("input#FIELD_DEFAULT").val(); 
			SubTable2Obj.ObjectType = $(this).find("SELECT#OBJECT_TYPE").val() == null ? "" : $(this).find("SELECT#OBJECT_TYPE").val();	
						
			SubTable2Array.push(SubTable2Obj);			
		});	
			
		if(SubTable2Array.length > 0){
			SubTableInfoObj.SubTable2 = SubTable2Array;
		}
		
				
		var SubTable3Array = new Array();		
		jQuery.ajaxSettings.traditional = true;
		$("#Sub_FieldTable3 tr:not(:first)").each(function(i){
			var SubTable3Obj = new Object();
			
			SubTable3Obj.FieldName = $(this).find("input#FIELD_NAME").val();
			SubTable3Obj.FieldLabel = $(this).find("input#FIELD_LABEL").val();
			SubTable3Obj.FieldType = $(this).find("SELECT#FIELD_TYPE").val() == null ? "" : $(this).find("SELECT#FIELD_TYPE").val();
			SubTable3Obj.FieldLength = $(this).find("input#FIELD_LENGTH").val();
			SubTable3Obj.FieldDefault = $(this).find("input#FIELD_DEFAULT").val(); 
			SubTable3Obj.ObjectType = $(this).find("SELECT#OBJECT_TYPE").val() == null ? "" : $(this).find("SELECT#OBJECT_TYPE").val();	
						
			SubTable3Array.push(SubTable3Obj);			
		});	
						
		if(SubTable3Array.length > 0){
			SubTableInfoObj.SubTable3 = SubTable3Array;
		}
			
		
		var SubTable4Array = new Array();		
		jQuery.ajaxSettings.traditional = true;
		$("#Sub_FieldTable4 tr:not(:first)").each(function(i){
			var SubTable4Obj = new Object();
			
			SubTable4Obj.FieldName = $(this).find("input#FIELD_NAME").val();
			SubTable4Obj.FieldLabel = $(this).find("input#FIELD_LABEL").val();
			SubTable4Obj.FieldType = $(this).find("SELECT#FIELD_TYPE").val() == null ? "" : $(this).find("SELECT#FIELD_TYPE").val();
			SubTable4Obj.FieldLength = $(this).find("input#FIELD_LENGTH").val();
			SubTable4Obj.FieldDefault = $(this).find("input#FIELD_DEFAULT").val();
			SubTable4Obj.ObjectType = $(this).find("SELECT#OBJECT_TYPE").val() == null ? "" : $(this).find("SELECT#OBJECT_TYPE").val();	
			
			SubTable4Array.push(SubTable4Obj);			
		});					
		
		if(SubTable4Array.length > 0){
			SubTableInfoObj.SubTable4 = SubTable4Array;
		}
		
		//jsavaScript 객체를 JSON 객체로 변환
		SubTableInfo = JSON.stringify(SubTableInfoObj);
		
		var ajaxUrl;
		
		if(mode=="modify"){
			ajaxUrl = "updateAdminFormData.do";
		}else{
			ajaxUrl = "insertAdminFormData.do";
		}
		
		$.ajax({
			url:ajaxUrl,
			type:"post",
			data: {
				"FormID" : paramFormID
				,"FormClassID" : FormClassID
				,"SchemaID" : SchemaID
				,"IsUse" : IsUse
				,"Revision" : Revision
				,"SortKey" : SortKey
				,"FormName" : FormName
				,"FormPrefix" : FormPrefix
				,"FormDesc" : FormDesc
				,"sourcefile" : sourcefile
				,"FileName" : FileName
				,"BodyDefault" : BodyDefault
				,"BodyDefaultInlineImage" : BodyDefaultInlineImage
				,"BodyBackgroundImage" : BodyBackgroundImage
				,"ExtInfo" : ExtInfo
				,"AutoApprovalLine" : AutoApprovalLine
				,"BodyType" : BodyType
				,"SubTableInfo" : SubTableInfo
				,"IsEditFormHelper" : IsEditFormHelper	
				,"FormHelperContext" : FormHelperContext
				,"FormHelperImages" : FormHelperImages
				,"IsEditFormNotice" : IsEditFormNotice
				,"FormNoticeContext" : FormNoticeContext
				,"FormNoticeImages" : FormNoticeImages
				,"AuthDept" : AuthDept //Reserved1
				//,"Reserved2" : Reserved2
				//,"Reserved3" : Reserved3
				//,"Reserved4" : Reserved4
				//,"Reserved5" : Reserved5
				,"Mode" : mode
				,"CompanyCode" : CompanyCode
				,"OrgFileEntCode" : OrgFileEntCode
				,"AclAllYN" : AclAllYN
				,"FormIcon" : FormIcon
			},
			async:false,
			success:function (res) {
				if(res.data == 1){
					Common.Inform("<spring:message code='Cache.msg_apv_331' />","Inform",function() {		//"저장되었습니다."
						//parent.Refresh();
						parent.cmdSearch(); // 검색조건 초기화 되지 않도록 새로고침 => 검색으로 변경
						closeLayer();
					});
				} else {
					Common.Error(res.message,"Error");
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(ajaxUrl, response, status, error);
			}
		});
	}
	
	
	
	// 삭제 버튼 클릭
	function btnDelete_Click(){
		Common.Confirm("<spring:message code='Cache.msg_apv_095' />", "Confirmation Dialog", function(result){		//이 양식정의를 사용하여 생성되었던 기존의 모든 결재문서(진행, 완료 등)가 삭제되며 복구 되지 않습니다. 계속 진행하시겠습니까?
			if(!result){
				return false;
			}else{
				$.ajax({
					url:"deleteAdminFormData.do",
					type:"post",
					data: {
						"FormID" : paramFormID				
					},
					async:false,
					success:function (res) {
						if(res.data == 1){
							Common.Inform("<spring:message code='Cache.msg_50' />","Inform",function() {		//삭제되었습니다.
								//parent.Refresh();
								parent.cmdSearch(); // 검색조건 초기화 되지 않도록 새로고침 => 검색으로 변경
								closeLayer();
							});
						} else {
							Common.Error(res.message,"Error", function(){
								//parent.Refresh();
								parent.cmdSearch(); // 검색조건 초기화 되지 않도록 새로고침 => 검색으로 변경
								closeLayer();
							});
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteAdminFormData.do", response, status, error);
					}
				});
			}
		});
	}
	
	// json data 생성
	function makeJSON(){
		var obj = {};

		$("input[name=id],input[name=name],input[name=desc],input[name=pdef],input[name=pdefname]").each(function () {
			obj[$(this).attr("name")] = {};
			obj[$(this).attr("name")]["isUse"] = true;
			obj[$(this).attr("name")]["type"] = "string";
			obj[$(this).attr("name")]["value"] = $(this).val();
			obj[$(this).attr("name")]["desc"] = "";
			
			if($(this).attr("name") == "id" && mode == "add") obj[$(this).attr("name")]["value"] = Common.getUUID();
		});
		
		$("input[type=checkbox]").each(function () {
			var type;
			var data;
			var hasData = false;
			
			hasData = $(this).parent().parent().find("input[type=text],select").length > 0 ? true : false;
			
			if(hasData){
				type = typeof($(this).parent().parent().find("input[type=text],select").val());
				data = $(this).parent().parent().find("input[type=text],select").val();
			} else {
				type = "";
				data = "";
			}
			
			obj[$(this).attr("name")] = {};
			obj[$(this).attr("name")]["isUse"] = $(this).is(":checked");
			obj[$(this).attr("name")]["type"] = type;
			obj[$(this).attr("name")]["value"] = data;
			obj[$(this).attr("name")]["desc"] = (($("#" + $(this).attr("name") + "DESC") == undefined) ? "" : $("#" + $(this).attr("name") + "DESC").text()).replaceAll("\n","");
		});
		
		return obj;
	}
	
	//검색창에서 전달받은 데이터 적용
	function setPDEFID(pPDEFID, pPDEFName){
		$("input[name=pdef]").val(pPDEFID);
		$("input[name=pdefname]").val(pPDEFName);
	}
	
	parent._CallBackMethod = setPDEFID;
	
	// ProcessDefinition 검색 팝업
	function showProcessDefinitionPopup() {
		parent.Common.open("","processDefinitionSearch","<spring:message code='Cache.lbl_apv_search'/>","/approval/manage/processdefinitionsearch_popup.do?PDEF_ID=" + $("input[name=pdef]").val(),"600px","510px","iframe",true,null,null,true);
	}
	
	
	
    //신규생성/기존파일이용 레디오버튼 클릭
    function ChangeFormCreateKind(kind)
    {
        if(kind == 1)  //신규생성
        {
            $('#divNewCreate').css({"display":""});  
            $('#divOldFileUse').css({"display":"none"});  
            $('#FormCreateKind').val("1"); 

            if (mode != "SaveAs")  //버젼업모드
                MakeFormFileNm();
        }
        else  //기존파일이용
        {
        	$("#sourcefile").val("");
            $('#divNewCreate').css({"display":"none"});  
            $('#divOldFileUse').css({"display":""}); 
            $('#FormCreateKind').val("2"); 
        }

        //$("#sourcefile").val("");
        //$("#flnm").val("");
        //$("#tpnm").val("");
    }
    
    //양식파일명 자동대입
    function MakeFormFileNm()
    {
        var vFormKey = $("#fmpf").val();
        var vVersion = $("#fmrv").val();
        if(vVersion == "")
            vVersion = "0";

        if(vFormKey != "")
            $("#flnm").val(vFormKey+"_V"+vVersion+".html");
    }
    
    
    
	//양식 분류 select box 세팅
	function setselclass(){
		$.ajax({
			url:"getFormClassListSelectData.do",
			type:"post",
			data: {
				"entCode" : $("#selectCompanyCode").val()
			},
			async:false,
			success:function (data) {
				$("select[id='selclass'] option").remove();   
				$("#selclass").append("<option value=''>"+Common.getDic('lbl_apv_selection')+"</option>");
				for(var i=0; i<data.list.length;i++){
					$("#selclass").append("<option value='"+data.list[i].optionValue+"'>"+data.list[i].optionText+"</option>");
					if(getFormClassID == data.list[i].optionValue){
						$("#selclass").val(getFormClassID).prop("selected", true);
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getFormClassListSelectData.do", response, status, error);
			}
		});
	}
	
	/*
	//axisj selectbox변환
	function selSelectbind(){
		//사용여부selectbind
		$("#fmst").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		 
		//보안등급selectbind
		$("#SecurityGrade").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
		//보존년한selectbind
		$("#PreservPeriod").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
	}
	*/
	
	function ChangeEntCode(){
		setselclass();
		setselschema();
	}
	
	//양식프로세스  select box 세팅
	function setselschema(){
		$.ajax({
			type:"POST",
			data:{	
				"entCode" : $("#selectCompanyCode").val()
			},
			async:false,
			url:"getSchemaListSelectData.do",
			success:function (data) {	
				$("select[id='selschema'] option").remove();
				$("#selschema").append("<option value=''>"+Common.getDic('lbl_apv_selection')+"</option>");
				for(var i=0; i<data.list.length;i++){					
					$("#selschema").append("<option value='"+data.list[i].optionValue+"'>"+data.list[i].optionText+"</option>");
					if(getSchemaID == data.list[i].optionValue){
						$("#selschema").val(getSchemaID).prop("selected", true);
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getSchemaListSelectData.do", response, status, error);
			}
		});	
	}
	
	// 회사리스트 셋팅
	function setEntList(){
		//data 조회
		var EntList = "../common/getEntInfoListDefaultData.do";
		if(Common.getSession("DN_Code") != "ORGROOT") EntList = "../common/getEntInfoListAssignData.do";

		$.ajax({
			type:"POST",
			data:{				
			},
			url:EntList,
			async:false,
			success:function (data) {
				for(var i=0; i<data.list.length;i++){	
					arrEntCode.push(data.list[i].optionValue);
					$("#selectCompanyCode").append("<option value='"+data.list[i].optionValue+"'>"+data.list[i].optionText+"</option>");
					$("#divEntMailList").append("<input type='checkbox' name='chkMailauth' id='chkauth' value='" + data.list[i].optionValue + "' class='input_check' onclick='javascript:chkMailauth_onclick();' />" + data.list[i].optionText );						
				}
				$("#divEntMailList").append("<spring:message code='Cache.lbl_EntMailListExplain'/>");
				$("#divEntMailList").show();
				
				// 전결 규정 리스트
				
				if('${strisSaaS}' != "Y" || Common.getSession("DN_Code") == "ORGROOT"){
	 				$("#selectEntList").append("<option value=''>전체</option>");
				}
				$(data.list).each(function(index){					
					$("#selectEntList").append("<option value='"+this.optionValue+"'>"+this.optionText+"</option>");
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("common/getEntInfoListDefaultData.do", response, status, error);
			}
		});
		
		// domainID Map List (Code : ID)
		$.ajax({
			type:"POST",
			url:"/approval/common/getEntInfoListData.do",
			data:{"type" : "ID"},
			async:false,
			success:function (data) {
				window.domainCodeMapping = {};
				for(var i=0; i<data.list.length;i++){	
					var __domainID = data.list[i].optionValue// domainID
					var __domainCode = data.list[i].defaultVal // domainCode
					window.domainCodeMapping[__domainCode] = __domainID; 
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("common/getEntInfoListData.do", response, status, error);
			}
		});
	}
	
	// 전결 규정 리스트
	function setRuleItemDiv(selEntCode, reqType) {
		var len = typeof(ruleItemLists) == "undefined" ? 0 : ruleItemLists.length;
		
		// 계열사 관리자가 공통양식 설정에서 본인 회사 설정만 변경하는 경우, 타 회사 설정이 유지되도록 설계 변경(전체를 로드하고, 본인회사 규정만 보이도록)
		/*
		if (mode == "modify" && reqType == "load" && len == 1) {
			$("#selectEntList").val(ruleItemLists[0].DNCode);
		} else {
			$("#selectEntList").val(selEntCode);
		}
		*/
		// 전결규정 회사 종류가1 개이고 권한있는 회사인경우
		if (mode == "modify" && reqType == "load" && len == 1) {
			if($("#selectEntList").find("option[value='" + ruleItemLists[0].DNCode + "']").length == 1) {
				$("#selectEntList").val(ruleItemLists[0].DNCode);
				selEntCode = ruleItemLists[0].DNCode;
			}
		}
		
		if(reqType == "load"){
			if($("#selectEntList").find("option").length > 0){
				$.ajax({
					type:"POST",
					data:{"entCode" : ""},
					url:"../manage/getRuleForForm.do",
					async:false,
					success:function (data) {
						$("#ruleItemDiv").empty();
						var html = "";
						$(data.list).each(function(i) {
							var flag = false;
							if(selEntCode == "" || selEntCode == this.EntCode) html += "<label style=\"display:block;margin-top:5px;\" entcode=\"" + this.EntCode + "\">";
							else html += "<label style=\"display:none;margin-top:5px;\" entcode=\"" + this.EntCode + "\">";
							
							for (var j=0; j<len; j++) {
								var arr = ruleItemLists[j].ruleitem;
								for (var k=0; k<arr.length; k++) {
									if (this.ItemCode == arr[k]) {
										html += "<span style=\"vertical-align: middle;\"><input style=\"margin-right:2px;\" type=\"checkbox\" name=\"ruleItem\" value=\""+this.EntCode+","+this.ItemCode+"\" checked/></span>";
										flag = true;
										break;
									}
								}
							}
							
							if (!flag) {
								html += "<span style=\"vertical-align: middle;\"><input style=\"margin-right:2px;\" type=\"checkbox\" name=\"ruleItem\" value=\""+this.EntCode+","+this.ItemCode+"\"/></span>";
							}
							html += "<span>"+this.path+"</span>";
							html += "</label>";
						});
						
						$("#ruleItemDiv").append(html);
					},
					error:function(response, status, error){
						CFN_ErrorAjax("manage/getRuleForForm.do", response, status, error);
					}
				});		
			}
		}else{
			$("#ruleItemDiv").find("label").each(function(idx,item){
				if($(item).attr("entcode") && (selEntCode == "" || selEntCode == $(item).attr("entcode"))){
					$(item).css("display","block");
				}else{
					$(item).css("display","none");
				}
			});
		}
	}	
	
	function chkMailauth_onclick() {
	    var l_oldAuthList = $("#FmMailList").val();
	    var l_aAuthList = l_oldAuthList.split("@");
	    var l_checked = "";	    
	    $("input[name='chkMailauth']").each(function (i) {	    	
	        if ($(this).is(":checked")) {
	            l_checked += ";" + $(this).val();
	            
	        }
	    });	   
	  
	    if (l_aAuthList.length > 1) {
	        $("#FmMailList").val(l_checked + "@" + l_aAuthList[1]);
	    } else {	    	
	        $("#FmMailList").val(l_checked);
	    }	 
	}
	
	function removeApprovalLinePeople(data,LineKey,LineKeyTwo){		
		$("#div"+LineKey).find("#div"+LineKeyTwo).find(jq("span"+data)).remove();
		//$("#div"+LineKey).find("#div"+CCAfterTreeClickDept).find("#lab"+data.jqid()).remove();
	}
	
	function toggleSerialCheckDiv(routeType, sCode) {
		var oldScode = $("#IsSerial"+routeType).attr("scode");
		
		var isSerial;
		if(routeType == "Agree"){
			isSerial = JSON.parse($("#divAgree").find("#ipt"+sCode).val()).isSerial;
		}else{
			isSerial = JSON.parse($("#divAssist").find("#ipt"+sCode).val()).isSerial;
		}		
		
		if(isSerial == "Y") {
			$("#IsSerial"+routeType).attr("class","ckeckOn");
		} else {
			$("#IsSerial"+routeType).attr("class","ckeckOff");
		}
		
		if(oldScode == sCode) {		
			if($("#IsSerial"+routeType).css("display") == "none") {
				$("#IsSerial"+routeType).show();
			} else {
				$("#IsSerial"+routeType).hide();	
			}
		} else {
			$("#IsSerial"+routeType).attr("scode", sCode);

			$("#IsSerial"+routeType).show();
		}
	}
	
	function jq( myid ) {		 			
		    return "#" + myid.replace( ".", "\\." );		 
		} 
	
	//조직도띄우기
	function OrgMap_Open(mapflag){		
		flag = mapflag;
		AutoApprovalLineKey = mapflag;
		
		if(AutoApprovalLineKey=="CCAfter"){
			if(axf.isEmpty(CCAfterTreeClickDept)){
				Common.Warning("<spring:message code='Cache.msg_apv_SelectOrgMap' />");		//조직도를 선택하세요
				return;
			}
		}
		if(AutoApprovalLineKey=="CCBefore"){
			if(axf.isEmpty(CCBeforeTreeClickDept)){
				Common.Warning("<spring:message code='Cache.msg_apv_SelectOrgMap' />");		//조직도를 선택하세요
				return;
			}
		}
		if(AutoApprovalLineKey=="Approval"){
			if(axf.isEmpty(ApprovalTreeClickDept)){
				Common.Warning("<spring:message code='Cache.msg_apv_SelectOrgMap' />");		//조직도를 선택하세요
				return;
			}
		}
		if(AutoApprovalLineKey=="Agree"){
			if(axf.isEmpty(AgreeTreeClickDept)){
				Common.Warning("<spring:message code='Cache.msg_apv_SelectOrgMap' />");		//조직도를 선택하세요
				return;
			}
		}
		if(AutoApprovalLineKey=="Assist"){
			if(axf.isEmpty(AssistTreeClickDept)){
				Common.Warning("<spring:message code='Cache.msg_apv_SelectOrgMap' />");		//조직도를 선택하세요
				return;
			}
		}
		var strType = "";
		if(mapflag=="0"){
			strType = "C9";
		}else if(mapflag=="1"){
			strType = "D9";
		}else if(AutoApprovalLineKey=="CCAfter"||AutoApprovalLineKey=="CCBefore"||AutoApprovalLineKey=="Agree"||AutoApprovalLineKey=="Assist"){
			strType = "D9";
		}else if(AutoApprovalLineKey=="Approval") {
			// 자동 결재자, 합의자, 협조자는 부서선택 불가 => 추가 개발 필요
			strType = "B9";
		}
		
		
		if(mapflag=="1"){
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_adminFrmPopCallback&type="+strType+"&setParamData=_setParamdata","1060px","580px","iframe",true,null,null,true);	
		}else if(mapflag=="0"){
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_adminFrmPopCallback&type="+strType+"&setParamData=_setParamdataAuth","1060px","580px","iframe",true,null,null,true);	
		}else if(AutoApprovalLineKey=="CCAfter"||AutoApprovalLineKey=="CCBefore"||AutoApprovalLineKey=="Approval"||AutoApprovalLineKey=="Agree"||AutoApprovalLineKey=="Assist"){
			var tmp = {};
			
			if(AutoApprovalLineKey=="CCAfter") {
				$($("#div" + AutoApprovalLineKey + " > #div" + CCAfterTreeClickDept).find("input[type='hidden']")).each(function (i, obj) {
					//$.extend(tmp, {"item": JSON.parse($(obj).val())});
					$$(tmp).append("item", JSON.parse($(obj).val()));
				});
			}
			else if(AutoApprovalLineKey=="CCBefore") {
				$($("#div" + AutoApprovalLineKey + " > #div" + CCBeforeTreeClickDept).find("input[type='hidden']")).each(function (i, obj) {
					$$(tmp).append("item", JSON.parse($(obj).val()));
				});
			}
			else if(AutoApprovalLineKey=="Approval") {
				$($("#div" + AutoApprovalLineKey + " > #div" + ApprovalTreeClickDept).find("input[type='hidden']")).each(function (i, obj) {
					$$(tmp).append("item", JSON.parse($(obj).val()));
				});
			}
			else if(AutoApprovalLineKey=="Agree") {
				$($("#div" + AutoApprovalLineKey + " > #div" + AgreeTreeClickDept).find("input[type='hidden']")).each(function (i, obj) {
					$$(tmp).append("item", JSON.parse($(obj).val()));
				});
			}
			else if(AutoApprovalLineKey=="Assist") {
				$($("#div" + AutoApprovalLineKey + " > #div" + AssistTreeClickDept).find("input[type='hidden']")).each(function (i, obj) {
					$$(tmp).append("item", JSON.parse($(obj).val()));
				});
			}
			
			parent._setParamdata = JSON.stringify(tmp);
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_adminFrmPopCallback&type="+strType+"&setParamData=_setParamdata","1060px","580px","iframe",true,null,null,true);
		}else{
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_adminFrmPopCallback&type="+strType,"1060px","580px","iframe",true,null,null,true);
		}
		
	}
	
	
	parent._setParamdata = {};
	parent._setParamdataAuth = {};
/* 	function setParamdata(paramszObject){
		return $("#HiddenViewReportXML").val();
	} */
	
	//조직도선택후처리관련
	var peopleObj = {};
	parent._adminFrmPopCallback = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){
		var displayName = ''; //사용자에게 표시될 문자열
		var saveString = ''; //저장될 문자열
		var dataObj = $.parseJSON(peopleValue);	
		var l_checkedname = "";
		
		$(dataObj.item).each(function(i){
			if(AutoApprovalLineKey=="CCAfter"){					
				var sCode = dataObj.item[i].AN;	
		        var sName = CFN_GetDicInfo(dataObj.item[i].DN);				       
		        var peopleData = JSON.stringify(dataObj.item[i]);
		     
		        if($("#div" + AutoApprovalLineKey + " > #div" + CCAfterTreeClickDept).find("input[id='ipt" + sCode + "']").length > 0) return;
		        
		        var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+peopleData+"'>"
		        html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+AutoApprovalLineKey+"\",\""+CCAfterTreeClickDept+"\"); return false;'>삭제</a></span>";
		        $("#div"+AutoApprovalLineKey).find("#div"+CCAfterTreeClickDept).append(html);
		        
			}
			if(AutoApprovalLineKey=="CCBefore"){									
				var sCode = dataObj.item[i].AN;	
		        var sName = CFN_GetDicInfo(dataObj.item[i].DN);				       
		        var peopleData = JSON.stringify(dataObj.item[i]);
		        
		        if($("#div" + AutoApprovalLineKey + " > #div" + CCBeforeTreeClickDept).find("input[id='ipt" + sCode + "']").length > 0) return;
		        
		        var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+peopleData+"'>"
		        html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+AutoApprovalLineKey+"\",\""+CCBeforeTreeClickDept+"\"); return false;'>삭제</a></span>";				        
		        $("#div"+AutoApprovalLineKey).find("#div"+CCBeforeTreeClickDept).append(html);
			}
			if(AutoApprovalLineKey=="Approval"){													
				var sCode = dataObj.item[i].AN;	
		        var sName = CFN_GetDicInfo(dataObj.item[i].DN);				       
		        var peopleData = JSON.stringify(dataObj.item[i]);
		        
		        if($("#div" + AutoApprovalLineKey + " > #div" + ApprovalTreeClickDept).find("input[id='ipt" + sCode + "']").length > 0) return;
		        				        
		        var html = "<span class='delBox' id='span"+sCode+"'>"+sName+"<input type='hidden' id='ipt"+sCode+"' value='"+peopleData+"'>"
		        html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+AutoApprovalLineKey+"\",\""+ApprovalTreeClickDept+"\"); return false;'>삭제</a></span>";
		        $("#div"+AutoApprovalLineKey).find("#div"+ApprovalTreeClickDept).append(html);
			}
			if(AutoApprovalLineKey=="Agree"){									
				var sCode = dataObj.item[i].AN;	
		        var sName = CFN_GetDicInfo(dataObj.item[i].DN);				       
		        var peopleData = JSON.stringify(dataObj.item[i]);
		        				        
		        if($("#div" + AutoApprovalLineKey + " > #div" + AgreeTreeClickDept).find("input[id='ipt" + sCode + "']").length > 0) return;
		        
		        var html = "<span class='delBox' id='span"+sCode+"'><a onclick='toggleSerialCheckDiv(\"Agree\", \""+sCode+"\")'>"+sName+"</a><input type='hidden' id='ipt"+sCode+"' value='"+peopleData+"'>"
		        html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+AutoApprovalLineKey+"\",\""+AgreeTreeClickDept+"\"); return false;'>삭제</a></span>";
		        $("#div"+AutoApprovalLineKey).find("#div"+AgreeTreeClickDept).append(html);
			}
			if(AutoApprovalLineKey=="Assist"){									
				var sCode = dataObj.item[i].AN;	
		        var sName = CFN_GetDicInfo(dataObj.item[i].DN);				       
		        var peopleData = JSON.stringify(dataObj.item[i]);
		        				        
		        if($("#div" + AutoApprovalLineKey + " > #div" + AssistTreeClickDept).find("input[id='ipt" + sCode + "']").length > 0) return;
		        
		        var html = "<span class='delBox' id='span"+sCode+"'><a onclick='toggleSerialCheckDiv(\"Assist\", \""+sCode+"\")'>"+sName+"</a><input type='hidden' id='ipt"+sCode+"' value='"+peopleData+"'>"
		        html += "<a class='iDel' onClick='removeApprovalLinePeople(\""+sCode+"\",\""+AutoApprovalLineKey+"\",\""+AssistTreeClickDept+"\"); return false;'>삭제</a></span>";
		        $("#div"+AutoApprovalLineKey).find("#div"+AssistTreeClickDept).append(html);
			}
			
			if(flag==1){			
				var sCode = dataObj.item[i].AN;	
		        var sName = CFN_GetDicInfo(dataObj.item[i].DN);
		        var deptName = dataObj.item[i].GroupName; //부서명가져오기	
		        if(dataObj.item[i].itemType=="group") {
		        	deptName=null;
		        }
	            displayName += (displayName != '' ? ',' : '') + (sName + (deptName != null && deptName != undefined ? '(' + deptName + ')' : ''));
	            saveString += (saveString != '' ? '^' : '') + (sCode + '@' + sName); // + (deptName != null && deptName[0] != undefined ? '(' + deptName[0] + ')' : '');			
			}			
		});	
		
		if(flag==1){
			$("#TxtViewReport").val(displayName);
			$("#HiddenViewReport").val(saveString);
			$("#HiddenViewReportXML").val(JSON.stringify(dataObj));
			parent._setParamdata = dataObj;
		}
		
		if(flag==0){
			parent._setParamdataAuth = dataObj;
			
			if(dataObj && dataObj.item && dataObj.item.length > 0){
				$("#AclAllYN_N").prop("checked", true).trigger("change");
			}else{
				$("#AclAllYN_Y").prop("checked", true).trigger("change");
			}
		}
	}
	
	// HTML양식파일명 선택 버튼에 대한 레이어 팝업
	function SelectOrginFile(param){
		var pModal = true;
		var isSaaS = '${strisSaaS}';
		var setEntCode = $("#selectCompanyCode").val();
		objPopup = parent.Common.open("","SelectOrginFile","원본양식파일 선택","/approval/manage/goFormFileList.do?mode=add&paramEntCode="+param+"&isSaaS="+isSaaS+"&setEntCode="+setEntCode,"330px","400px","iframe",pModal,null,null,true);
	}
	
	function openSchema(){
		var pModal = true;
		var schema_Id = $("#selschema").val();
		objPopup = parent.Common.open("","schemaDetailPopup","전자결재 진행 환경 설정을 합니다.","/approval/manage/addschemalayerpopup.do?mode=modify&id="+schema_Id,"1000px","600px","iframe",pModal,null,null,true);		           
    }
	
	parent._domainCode = GetOrgFileEntCode;
	function GetOrgFileEntCode(pram){
		OrgFileEntCode = pram;
	}
	
	parent._CallBackMethod3 = SelFormFile;
	function SelFormFile(pFileNm){			
		if ($("#rdoNewCreate").is(":checked"))  //신규양식생성
	    {
			$("#sourcefile").val(pFileNm);	            
	        $('#sourcefile').focus();
	    }
		
	    if ($("#rdoOldFileUse").is(":checked"))  //기존양식이용
	    {
	        $("#UsingExistFile").val(pFileNm);
	        parent.Common.Close("divSelOrginFormFile");
	        $('#UsingExistFile').focus();
	    }
	    
	    // 공공데모 수정안
	    if(pFileNm == "WF_FORM_DRAFT_V0.html") {
	    	$("#UseEditYN").prop("checked", true);
	    	$("#UseHWPEditYN").prop("checked", false);
	    	
	    	ViewOrHideUseEditYN($("#UseEditYN"));
	    }
	    else if(pFileNm == "WF_FORM_DRAFT_HWP_V0.html") {
	    	$("#UseEditYN").prop("checked", false);
	    	$("#UseHWPEditYN").prop("checked", true);
	    	
	    	ViewOrHideUseEditYN($("#UseHWPEditYN"));
		}
	    else if(pFileNm == "NEW_WF_OFFICEITEM_V0.html") {
	    	$("#UseEditYN").prop("checked", false);
	    	$("#UseHWPEditYN").prop("checked", false);
	    	
	    	ViewOrHideUseEditYN($("#UseHWPEditYN"));
		}
	}
	
    //웹에디터 Visible/Invisible
    function ViewOrHideUseEditYN(obj)
    {
    	// 공공데모 수정안
	    /* if($("#sourcefile").val() == "WF_FORM_DRAFT_V0.html" || $("#UsingExistFile").val() == "WF_FORM_DRAFT_V0.html") {
	    	$("#UseEditYN").prop("checked", true);
	    	$("#UseHWPEditYN").prop("checked", false);
	    }
	    else if($("#sourcefile").val() == "WF_FORM_DRAFT_HWP_V0.html" || $("#UsingExistFile").val() == "WF_FORM_DRAFT_HWP_V0.html") {
	    	$("#UseEditYN").prop("checked", false);
	    	$("#UseHWPEditYN").prop("checked", true);
		}
	    else if($("#sourcefile").val() == "NEW_WF_OFFICEITEM_V0.html" || $("#UsingExistFile").val() == "NEW_WF_OFFICEITEM_V0.html") {
	    	$("#UseEditYN").prop("checked", false);
	    	$("#UseHWPEditYN").prop("checked", false);
		} */
    	
    	changeUseHWPEditYN(obj);
    	
        if($("#UseEditYN").is(":checked")) {
        	$("#UseWebHWPEditYN").parents("tr:not([visibleFixed])").hide();

            $('#divWebEditor:not([visibleFixed])').css({"display":""}); 
        }else{
        	$("#UseWebHWPEditYN").parents("tr:not([visibleFixed])").show();
        	
            $('#divWebEditor:not([visibleFixed])').css({"display":"none"}); 
        }
        //레이어높이 조정
       // PageResize();
    }

    //20180411 HWP에디터 사용 유무  
    //20200806 웹한글기안기 추가
    function changeUseHWPEditYN(obj){
        if($(obj).attr("id") == "UseHWPEditYN" && $(obj).is(":checked")) {
        	$("#UseEditYN").prop("checked", false);
        }
        else if($(obj).attr("id") == "UseEditYN" && $(obj).is(":checked")) {
        	$("#UseHWPEditYN").prop("checked", false);
        	$("#UseWebHWPEditYN").prop("checked", false);
        }
    }
    
    // 동시에 사용되면 안되는 옵션 체크 및 비활성화
    function DisableSpecificOpt(pObj) {
    	switch($(pObj).attr("id")) {
    	case "MobileFormYN":
    		if($(pObj).is(":checked")) {
    			$("#UseMultiEditYN").prop("checked", false);
    		}
    		
			$("#UseMultiEditYN").prop("disabled", $(pObj).is(":checked"));
    		break;
    	case "UseMultiEditYN":
    		if($(pObj).is(":checked")) {
    			$("#MobileFormYN").prop("checked", false);
    		}
    		
			$("#MobileFormYN").prop("disabled", $(pObj).is(":checked"));
    		break;
    	}
    }
    
    // 하위테이블 사용시 FormPrefix 가 변경 되는 경우, 테이블명 바뀌기
    function SetSubTableName(){
    	$("input[id^=CanWrite]").each(function(){
    		var tableNameObj = $(this).parent().parent().parent().find("[type=text]");
    		var isCheckDupObj = $(this).parent().parent().parent().find("[type=hidden]");
    		
    		if(!$(this).is(":checked") && $(tableNameObj).attr("readonly") == "readonly"){
    			var subTableType = $(this).attr("id").replace("CanWrite", "");
    	    	var tableName = $("#fmpf").val() + "_V" +$("#fmrv").val() + "_"+ subTableType;
    	    	$(tableNameObj).val(tableName);
    	    	$(isCheckDupObj).val("N");
    		}
    	});
    }
    
    // 하위테이블 사용여부 체크
    function IsUseSubTables(obj){
    	var isDisabled = true;
    	var isReadOnly = false;
		var tableName = "";
		var setValue = "N";
		var className ="chkeckSubTableOff";
		var IsHideAddRemoveBtn = true;
		
		var subTableID = $(obj)[0].id;
		var subTableType = $(obj)[0].id.replace("IsUse", "");
    	
    	if($(obj)[0].value == "Y"){		// 비사용
    		isDisabled = true;
    		isReadOnly = false;
    		setValue = "N";
    		className = "chkeckSubTableOff";
    		IsHideAddRemoveBtn = true;
    		//$("#"+subTableID).parent().find("[type=checkbox]").attr('checked', false);			// 직접입력 체크 박스
    		$("#CanWrite" + subTableType).attr('checked', false);			// 직접입력 체크 박스
    	}else{									// 사용
    		isDisabled = false;
    		isReadOnly = true;
    		if($("#fmrv").val() == ""){
    			$("#fmrv").val("0");
    		}
    		if($("#fmpf").val() == ""){			// FormPrefix 값 확인
    			Common.Warning("<spring:message code='Cache.msg_apv_012' />");
    			isDisabled = false;
    			return;
    		}else{
    			setValue = "Y";
    			className = "chkeckSubTableOn";
    			IsHideAddRemoveBtn = false;
    			tableName = $("#fmpf").val() + "_V" +$("#fmrv").val() + "_"+ subTableType;
    		}
    	}
    	
    	$(obj)[0].value = setValue;
		$("#"+subTableID).attr("class",className);
		
		var subTableContent = $("[name="+$(obj).parents("tr").attr("name")+"]");		
		$("#CanWrite" + subTableType).attr("disabled", isDisabled);			// 직접입력 체크 박스
		$("#btnCheckDup" + subTableType).attr("disabled", isDisabled);		// 중복체크 버튼
		var subTableName = subTableContent.find("#MainTable,#SubTable1,#SubTable2,#SubTable3,#SubTable4");	// 테이블명 텍스트박스
		subTableName.attr("disabled", isDisabled);
		subTableName.attr('readonly', isReadOnly);
		subTableName.val(tableName);
		if(setValue == "N") subTableContent.find("table tr#fmfield").remove();	// 필드정보 부분 삭제
		//subTableContent.find("table tr#fmfield").find("input,select").attr("disabled",isDisabled);	// 필드정보 부분 disable
		
		if(IsHideAddRemoveBtn)
			$("#"+subTableType+"ColmAdd").hide();
		else
			$("#"+subTableType+"ColmAdd").show();
		
    	// 서브 테이블
    	if(subTableType != "Master"){
    		$("#SubSort"+subTableType.replace("Sub", "")) .attr("disabled", isDisabled);
    	}
    }
    
    // 하위테이블명 직접입력 체크
    function canWriteTableName(obj){
    	var isReadOnly = false;
    	
    	isReadOnly = $(obj).parent().parent().parent().find("[type=text]").attr("readonly");
    	
    	$(obj).parent().parent().parent().find("[type=text]").attr("readonly", !isReadOnly);		// 테이블명
    	
    	if(!isReadOnly){
    		var subTableType = $(obj)[0].id.replace("CanWrite", "");
	    	var tableName = $("#fmpf").val() + "_V" +$("#fmrv").val() + "_"+ subTableType;
	    	$(obj).parent().parent().parent().find("[type=text]").val(tableName);		// 테이블명
    	}
    }
    
    //하위테이블명 중복체크
    function checkDupSubTable(obj){
    	var tableName = $(obj).parent().find("[type=text]").val();
    	var isCheckDupObj = $(obj).parent().find("[type=hidden]");
    	
    	$.ajax({
			url:"checkDuplidationTableName.do",
			type:"POST",
			data:{
				"tableName" : tableName
			},
			async:false,
			success:function (data) {
				if(data.result){
					Common.Inform("<spring:message code='Cache.lbl_apv_useOK' />");		// 사용 가능합니다.
					$(isCheckDupObj).val("Y");
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_doubled' />");		// 중복입니다.
					$(isCheckDupObj).val("N");
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("checkDuplidationTableName.do", response, status, error);
			}
    	});
    }
    
  	//하위테이블구성 추가 필드 입력란 생성
    function addSubTableFieldRow(tableID, obj) {
    	if ($("#" + tableID).find("tr").length > 100) { Common.Warning("<spring:message code='Cache.msg_apv_addFieldRowOverflow' />"); return; }		//추가필드는 100개까지입니다. 더이상 추가 할수 없습니다.
        var eTR = document.getElementById(tableID).insertRow(-1);
        eTR.id = "fmfield";

        var eTD;
        eTD = eTR.insertCell(-1);
        eTD.innerHTML = "<input type='checkbox' id='chkField' name='chkField'>";
        eTD = eTR.insertCell(-1);
        eTD.innerHTML = "<input type='text' id='FIELD_NAME' name='FIELD_NAME' class='edit' style='ime-mode:inactive;' maxlength='30' required><input type='hidden' id='FIELD_ID' name='FIELD_ID' required/>";
        eTD = eTR.insertCell(-1);
        eTD.innerHTML = "<input type='text' id='FIELD_LABEL' name='FIELD_LABEL' class=edit maxlength='30' style='' required>";
        eTD = eTR.insertCell(-1);
        eTD.innerHTML = "<SELECT id='FIELD_TYPE' name='FIELD_TYPE' class='' onchange='event_FieldType();' style=''>"
    	+ "<OPTION VALUE='varchar'>VarChar</OPTION>"
    	+ "<OPTION VALUE='char'>Char</OPTION>"
    	+ "<OPTION VALUE='text'>Text</OPTION>"
    	+ "<OPTION VALUE='datetime'>DateTime</OPTION>"
    	+ "<OPTION VALUE='decimal'>Decimal</OPTION>"
    	+ "<OPTION VALUE='float'>Float</OPTION>"
    	+ "<OPTION VALUE='int'>Int</OPTION>"
    	//+ "<OPTION VALUE='nchar'>NChar</OPTION>"
    	//+ "<OPTION VALUE='ntext'>NText</OPTION>"
    	//+ "<OPTION VALUE='nvarchar'>NVarChar</OPTION>"
        //+ "<OPTION VALUE='money'>Money</OPTION>"
    	+ "</SELECT>";
        eTD = eTR.insertCell(-1);
        eTD.innerHTML = "<input type='text' id='FIELD_LENGTH' name='FIELD_LENGTH' class='edit' style=''>";
        eTD = eTR.insertCell(-1);
        eTD.innerHTML = "<input type='text' id='FIELD_DEFAULT' name='FIELD_DEFAULT' class='edit' style=''>";

        eTD = eTR.insertCell(-1);
        eTD.innerHTML = "<SELECT id='OBJECT_TYPE' name='OBJECT_TYPE' class=''>" // 이벤트 제거 onchange='event_ObjectType();' 
    	+ "<OPTION VALUE='text'>TEXT</OPTION>"
    	+ "<OPTION VALUE='select'>SELECT</OPTION>"
    	+ "<OPTION VALUE='checkbox'>CHECKBOX</OPTION>"
    	+ "<OPTION VALUE='radio'>RADIO</OPTION>"
    	+ "<OPTION VALUE='textarea'>TEXTAREA</OPTION>"
        /* 컴포넌트 추가 X Easy : KJW : 시작 */
        + "<OPTION VALUE='date'>DATE</OPTION>"
        + "<OPTION VALUE='numeric'>NUMERIC</OPTION>"
        + "<OPTION VALUE='currency'>CURRENCY</OPTION>"
        /* 컴포넌트 추가 X Easy : KJW : 끝 */
    	+ "</SELECT>";

        eTD.height = "20";
        eTD.valign = "top";
        eTD.noWrap = true;
        eTD.style.overflow = "hidden";
        eTD.style.paddingRight = "1px";

        //읽기일 때 데이터 바인딩
        if (obj != null) {
            $(eTR).find("input#FIELD_NAME").val($(obj).find("FieldName").text());
            $(eTR).find("input#FIELD_LABEL").val($(obj).find("FieldLabel").text());
            $(eTR).find("SELECT#FIELD_TYPE").val($(obj).find("FieldType").text());
            $(eTR).find("input#FIELD_LENGTH").val($(obj).find("FieldLength").text());
            $(eTR).find("input#FIELD_DEFAULT").val($(obj).find("FieldDefault").text());
            $(eTR).find("SELECT#OBJECT_TYPE").val($(obj).find("ObjectType").text());

            if (document.getElementById("hidFormFieldText") != undefined) {
                var tmp = $("textarea#hidFormFieldText").val();
                var sTbl = "";
                tableID == "SubMaster_FieldTable" ? sTbl = "master" : sTbl = tableID;
                if (tmp != "") tmp += "\r\n";
                tmp += sTbl + ";" + $(obj).find("FieldName").text() + ";" + $(obj).find("FieldLabel").text() + ";" + $(obj).find("FieldType").text() + ";" + $(obj).find("FieldLength").text() + ";" + $(obj).find("ObjectType").text();

                $("textarea#hidFormFieldText").val(tmp);
            }
        }

        $(eTR).find("input[type=text]").attr("onkeydown", "event_inputKeyDown(event);");    //키입력 이벤트
        //$(eTR).find("input#FIELD_NAME").attr("onblur", "event_chkFieldName(event);");    //Field Name 체크
        $(eTR).find("input[type=text]").attr("onblur", "event_chkField(event);");    //필수입력 체크
        $(eTR).find("SELECT#FIELD_TYPE").attr("onblur", "event_chkField(event);");    //필수입력 체크

        if (mode == "READ") {
            $(eTR).find("input[type=checkbox]").attr("disabled", "disabled");
            $(eTR).find("input[type=text]").attr("disabled", "disabled");
            $(eTR).find("select").attr("disabled", "disabled");
        }

        return eTR;
    }
	  	
	//하위테이블구성 추가 필드 삭제
    function deleteSubTableFieldRows(tableID) {
        var tbl = document.getElementById(tableID);
        var delCnt = 0;
        var tbLength = tbl.rows.length;
        for (var i = 0; i < tbLength; i++) {
            var tempChk = tbl.rows[i - delCnt].getElementsByTagName("input");
            if (tempChk[0] != null) {
                if (tempChk[0].checked) {
                    tbl.deleteRow(i - delCnt);
                    delCnt++;
                }
            }
        }
    }
	
    //하위테이블 추가필드 필드속성 이벤트
    function event_FieldType() {
        var el = event.srcElement;
        var elp = event.srcElement.parentElement.parentElement;
        var targetCell = elp.cells[4].firstChild;   //필드길이 input

        var arrFType = ['int', 'datetime', 'float', 'ntext', 'money', 'text'];   //필드길이가 없는 타입
        if ($.inArray($(el).val(), arrFType) >= 0) {
            $(targetCell).val("");
            $(targetCell).attr("readonly", "readonly");
        }
        else {
            $(targetCell).val("");
            $(targetCell).removeAttr("readonly");
        }
    }

    //하위테이블 추가필드 객체유형 이벤트
    function event_ObjectType() {
        var el = event.srcElement;
        var elp = event.srcElement.parentElement.parentElement;
        var typeCell = elp.cells[3].firstChild;   //필드속성 select
        var lenCell = elp.cells[4].firstChild;   //필드길이 input

        switch ($(el).val()) {
            /* 컴포넌트 추가 X Easy : KJW : 시작 */
            case "date":
                $(typeCell).val("varchar");
                $(lenCell).val("10");
                $(typeCell).attr("disabled", "disabled");
                $(lenCell).attr("disabled", "disabled");
                $(lenCell).attr("readonly", "readonly");
                break;
            case "numeric":
                $(typeCell).val("int");
                $(lenCell).val("");
                $(lenCell).attr("readonly", "readonly");
                break;
            /* case "currency":
                $(typeCell).val("money");
                $(lenCell).val("");
                $(lenCell).attr("readonly", "readonly");
                break; */
                /* 컴포넌트 추가 X Easy : KJW : 끝 */
            default:
                $(typeCell).removeAttr("disabled");
                $(lenCell).removeAttr("disabled");
                $(lenCell).removeAttr("readonly");
                break;
        }
    }
    
  //하위테이블 추가필드 입력 이벤트
    function event_inputKeyDown(event, obj) {
	  // 테이블명이 수정되었을 경우 다시 중복체크
        var el = event.srcElement;
        //[2015-11-05 LeeSM] SP명 입력받기 - SubTableSPName 추가
        if ($(el).attr("name") == "MainTable" || $(el).attr("name") == "SubTable1"
             || $(el).attr("name") == "SubTable2" || $(el).attr("name") == "SubTable3" || $(el).attr("name") == "SubTable4"
             || $(el).attr("name") == "SubSort1" || $(el).attr("name") == "SubSort2" || $(el).attr("name") == "SubSort3"
             || $(el).attr("name") == "SubSort4" || $(el).attr("name") == "SubTableSPName") {
            if (event.keyCode == 32) CFN_CancelEvent(event); //space 금지
            
            if($(obj).parent().find("input[id^=isCheckDup]").val() == "Y"){
            	$(obj).parent().find("input[id^=isCheckDup]").val("N");
            }
        }
        else {
            var elp = event.srcElement.parentElement.parentElement;
            var targetCell = elp.cells[4].firstChild;   //필드타입
            if ($(el).attr("name") == "FIELD_NAME") {
                if (event.keyCode == 32) CFN_CancelEvent(event); //space 금지
            }
            else if ($(el).attr("name") == "FIELD_LENGTH") {
                if (event.keyCode == 8 || event.keyCode == 9
                		|| event.keyCode == 13 || event.keyCode == 27 
                		|| event.keyCode == 46 || (event.keyCode == 65 && event.ctrlKey === true)
                		|| (event.keyCode >= 35 && event.keyCode <= 39)
                		|| ($(targetCell).val() == "decimal" && event.keyCode == 188)) {   // backspace || tab || || escape || delete || Ctrl+A || end(35), home(36), left(37), up(38), right(39)  필드타입이 decimal인 경우만 "," 입력 허용
                    return; // 해당 특수 문자만 허용
                } else {
                    if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105)) {//shift 이거나 || 0 ~ 9 이외 && 0(Ins) ~ 9(PgUp) 이외
                        CFN_CancelEvent(event); // 금지
                    } else {
                        return; // 숫자키만 허용
                    }
                }
            }
        }
    }

    //필수입력 체크
    function event_chkField(event) {
        var el = event.srcElement;
        var elId = $(el).attr("id");
        var elp = event.srcElement.parentElement.parentElement;
        var tblNm = $(event.srcElement.parentElement.parentElement.parentElement).attr("id");
        var nameCell = elp.cells[1].firstChild;   //필드ID
        var lableCell = elp.cells[3].firstChild;   //필드명
        var lengthCell = elp.cells[5].firstChild;   //필드길이
        var chkMsg = false;

        if (elId == "FIELD_NAME") {
            if($(el).val() && !new RegExp(/^[A-Za-z][A-Za-z0-9_]*$/).test($(el).val())){
            	Common.Warning("<spring:message code='Cache.msg_apv_chkInputTbName'/>"); // 문서키 필드ID는 입력할 수 없습니다.
                chkMsg = true;
            }
            
            if (tblNm == "MainTable") {
                if ($(el).val().toUpperCase() == "FORM_INST_ID") {
                	Common.Warning("<spring:message code='Cache.msg_apv_dockey_fieldID' />"); // 문서키 필드ID는 입력할 수 없습니다.
                    chkMsg = true;
                }
            } else {
                if ($(el).val().toUpperCase() == "FORM_INST_ID") {
                	Common.Warning("<spring:message code='Cache.msg_apv_dockey_fieldID' />"); // 문서키 필드ID는 입력할 수 없습니다.
                    chkMsg = true;
                }
                else if ($(el).val().toUpperCase() == "ROWSEQ") {
                	Common.Warning("<spring:message code='Cache.msg_apv_turn_fieldID' />"); // 순번 필드ID는 입력할 수 없습니다.
                    chkMsg = true;
                }
            }

            if (chkMsg) {
                $(el).val("");
                $(el).focus();
                return;
            }
        }

        /* if ($(nameCell).val() == "") {
        	Common.Warning("<spring:message code='Cache.msg_apv_355' />"); // 필드ID를 영어로 입력하십시오.
            $(el).val("");
            return;
        }

        if ($(lableCell).val() == "" && elId != "FIELD_NAME" && elId != "TH_NAME") {
        	Common.Warning("<spring:message code='Cache.msg_EnterFieldNm' />");  // 필드명을 입력하십시오.
            $(el).val("");
            return;
        }

        if ($(lengthCell).val() == "" && !$(lengthCell).attr("readonly")
                && elId != "FIELD_NAME" && elId != "TH_NAME" && elId != "FIELD_LABEL" && elId != "FIELD_TYPE") {
        	Common.Warning("<spring:message code='Cache.msg_apv_015' />");  // 필드 길이는 숫자로 입력하십시오.
            $(el).val("");
            return;
        } */
    }
    
	// 이벤트 취소
	function CFN_CancelEvent(event) {
		if ('cancelable' in event) {
			if (event.cancelable) {
				event.preventDefault();
			}
		} else {
			event.returnValue = false;
		}
	}
	
	///////////// 트리
	var CCAfterTree = new coviTree();
	var CCBeforeTree = new coviTree();
	var ApprovalTree = new coviTree();
	var AgreeTree = new coviTree();
	var AssistTree = new coviTree();
	
	var CCAfterTreebody = {
			onclick:function(){
				CCAfterTreeClickDept = this.item.nodeValue;
				$("#divCCAfter div").hide();				
				$("#divCCAfter").find("#div"+this.item.nodeValue).show();
			},
			ondblclick:function(){
			}
		};
	var CCBeforeTreebody = {
			onclick:function(){
				CCBeforeTreeClickDept = this.item.nodeValue;
				$("#divCCBefore div").hide();
				$("#divCCBefore").find("#div"+this.item.nodeValue).show();
			},
			ondblclick:function(){
			}
		};
	var ApprovalTreebody = {
			onclick:function(){
				ApprovalTreeClickDept = this.item.nodeValue;
				$("#divApproval div").hide();
				$("#divApproval").find("#div"+this.item.nodeValue).show();
			},
			ondblclick:function(){
			}
		};
	var AgreeTreebody = {

			onclick:function(){
				AgreeTreeClickDept = this.item.nodeValue;
				$("#divAgree div").hide();
				$("#divAgree").find("#div"+this.item.nodeValue).show();
			},
			ondblclick:function(){
			}
		};
	var AssistTreebody = {

			onclick:function(){
				AssistTreeClickDept = this.item.nodeValue;
				$("#divAssist div").hide();
				$("#divAssist").find("#div"+this.item.nodeValue).show();
			},
			ondblclick:function(){
			}
		};
	
	function setTreeData(){
		
		$.ajax({
			url:"getAutoApprovalLineDeptlist.do",
			type:"POST",
			data:{			
			},
			async:false,
			success:function (data) {
				// 계열사 관리자가 공통양식 설정에서 본인 회사 설정만 변경하는 경우, 타 회사 설정이 유지되도록 설계 변경(TreeData기준으로 설정을 로드하고 저장하므로 여기에는 전체를 로드하고, 실제 트리에는 본인회사 규정만 보이도록)
				TreeData = data.list;
				var List1 = new Object();
				var List2 = new Object();
				var List3 = new Object();
				var List4 = new Object();
				var List5 = new Object();
				 
				List1 = fileterEntCode(data.list, "nodeValue");
				List2 = fileterEntCode(data.list2, "nodeValue"); 
				List3 = fileterEntCode(data.list3, "nodeValue"); 
				List4 = fileterEntCode(data.list4, "nodeValue"); 
				List5 = fileterEntCode(data.list5, "nodeValue"); 
				
				CCAfterTree.setTreeList("CCAfterTree", List1, "nodeName", "220", "left", true, false ,CCAfterTreebody);
				CCBeforeTree.setTreeList("CCBeforeTree", List2, "nodeName", "220", "left", true, false ,CCBeforeTreebody);
				ApprovalTree.setTreeList("ApprovalTree", List3, "nodeName", "220", "left", true, false ,ApprovalTreebody);
				AgreeTree.setTreeList("AgreeTree", List4, "nodeName", "220", "left", true, false ,AgreeTreebody);
				AssistTree.setTreeList("AssistTree", List5, "nodeName", "220", "left", true, false ,AssistTreebody);
				
				for(var i = 0; i<data.list.length;i++){
					$("#divCCAfter").append("<div id='div"+data.list[i].nodeValue+"'></div>");
					$("#divCCBefore").append("<div id='div"+data.list[i].nodeValue+"'></div>");
					$("#divApproval").append("<div id='div"+data.list[i].nodeValue+"'></div>");
					$("#divAgree").append("<div id='div"+data.list[i].nodeValue+"'></div>");
					$("#divAssist").append("<div id='div"+data.list[i].nodeValue+"'></div>");
				}
				$("#divCCAfter div").hide();
				$("#divCCBefore div").hide();
				$("#divApproval div").hide();
				$("#divAgree div").hide();
				$("#divAssist div").hide();				
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getAutoApprovalLineDeptlist.do", response, status, error);
			}
		});
				
		//openAllTree();			// 트리를 모두 연 상태로 보여줌
	}
		
	
///////////// 사업장별 트리
	var CCAfterRegionTree = new coviTree();
	var CCBeforeRegionTree = new coviTree();
	var ApprovalRegionTree = new coviTree();
	var AgreeRegionTree = new coviTree();
	var AssistRegionTree = new coviTree();
	
	var CCAfterRegionTreebody = {
			onclick:function(){
				CCAfterTreeClickDept = this.item.nodeValue;	
				$("#divCCAfter div").hide();
				$("#divCCAfter").find("#div"+this.item.nodeValue).show();
			},
		};
	var CCBeforeRegionTreebody = {
			onclick:function(){
				CCBeforeTreeClickDept = this.item.nodeValue;
				$("#divCCBefore div").hide();
				$("#divCCBefore").find("#div"+this.item.nodeValue).show();
			},
		};
	var ApprovalRegionTreebody = {
			onclick:function(){
				ApprovalTreeClickDept = this.item.nodeValue;
				$("#divApproval div").hide();
				$("#divApproval").find("#div"+this.item.nodeValue).show();
			},
		};
	var AgreeRegionTreebody = {
			onclick:function(){
				AgreeTreeClickDept = this.item.nodeValue;
				$("#divAgree div").hide();
				$("#divAgree").find("#div"+this.item.nodeValue).show();
			},
		};
	var AssistRegionTreebody = {
			onclick:function(){
				AssistTreeClickDept = this.item.nodeValue;
				$("#divAssist div").hide();
				$("#divAssist").find("#div"+this.item.nodeValue).show();
			},
		};
	
	function setRegionTreeData(){
		
		$.ajax({
			url:"getAutoApprovalLineRegionlist.do",
			type:"POST",
			data:{			
			},
			async:false,
			success:function (data) {
				// 계열사 관리자가 공통양식 설정에서 본인 회사 설정만 변경하는 경우, 타 회사 설정이 유지되도록 설계 변경(TreeDataRegion기준으로 설정을 로드하고 저장하므로 여기에는 전체를 로드하고, 실제 트리에는 본인회사 규정만 보이도록)
				TreeDataRegion = data.list;
				var List1 = new Object();
				var List2 = new Object();
				var List3 = new Object();
				var List4 = new Object();
				var List5 = new Object();
				
				List1 = fileterEntCode(data.list, "dn_code");
				List2 = fileterEntCode(data.list2, "dn_code"); 
				List3 = fileterEntCode(data.list3, "dn_code"); 
				List4 = fileterEntCode(data.list4, "dn_code"); 
				List5 = fileterEntCode(data.list5, "dn_code"); 
				
				CCAfterRegionTree.setTreeList("CCAfterRegionTree", List1, "nodeName", "220", "left", true, false ,CCAfterRegionTreebody);
				CCBeforeRegionTree.setTreeList("CCBeforeRegionTree", List2, "nodeName", "220", "left", true, false ,CCBeforeRegionTreebody);
				ApprovalRegionTree.setTreeList("ApprovalRegionTree", List3, "nodeName", "220", "left", true, false ,ApprovalRegionTreebody);
				AgreeRegionTree.setTreeList("AgreeRegionTree", List4, "nodeName", "220", "left", true, false ,AgreeRegionTreebody);
				AssistRegionTree.setTreeList("AssistRegionTree", List5, "nodeName", "220", "left", true, false ,AssistRegionTreebody);
				
				for(var i = 0; i<data.list.length;i++){
					$("#divCCAfter").append("<div id='div"+data.list[i].nodeValue+"'></div>");
					$("#divCCBefore").append("<div id='div"+data.list[i].nodeValue+"'></div>");
					$("#divApproval").append("<div id='div"+data.list[i].nodeValue+"'></div>");
					$("#divAgree").append("<div id='div"+data.list[i].nodeValue+"'></div>");
					$("#divAssist").append("<div id='div"+data.list[i].nodeValue+"'></div>");
				}
				$("#divCCAfter div").hide();
				$("#divCCBefore div").hide();
				$("#divApproval div").hide();
				$("#divAgree div").hide();
				$("#divAssist div").hide();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getAutoApprovalLineRegionlist.do", response, status, error);
			}
		});
				
		//openAllTree();			// 트리를 모두 연 상태로 보여줌
	}
	
	// jsonarray에서 권한있는 회사정보 필터
	function fileterEntCode(pArr, pEntCodeKey){
		
		var filterResult = [];
		if(pArr && arrEntCode && pArr.length && arrEntCode.length){
			filterResult = pArr.filter(item => arrEntCode.includes(item[pEntCodeKey]));
		}
		
		return filterResult;
	}
	
	// 자동결재선 타입별 계열사별 이전 설정값 가져오기
	function getOldApvOptionYN(pTreeList, pNodeValue, pOldJsonAutoApprovalLine, pApvType, pEntType){
		var rtn = "N";
		
		if(!pTreeList.some(item => item.nodeValue == pNodeValue)){
			if(pOldJsonAutoApprovalLine && pOldJsonAutoApprovalLine[pApvType] && pOldJsonAutoApprovalLine[pApvType][pEntType] && pOldJsonAutoApprovalLine[pApvType][pEntType][pNodeValue]){
				rtn = pOldJsonAutoApprovalLine[pApvType][pEntType][pNodeValue].isUse;
			}
		}
		
		return rtn;
	}
	
	function setDocEditorApproval(sCallType){
	    //parent.Common.ShowDialog("btn_FormDocEditor", "btn_FormDocEditor", Common.getDic('lbl_form_editor'), sUrl + "?kind=" + sCallType + "&openID=divFormGenerator&OpenFrom=FormGenerator", sWidth, sHeight, "iframe-ifNoScroll");
	    parent.Common.open("","AdminFormDocEditor","<spring:message code='Cache.lbl_form_editor'/>","/approval/manage/goAdminFormDocEditor.do?kind=" + sCallType + "&openID=divFormGenerator&OpenFrom=FormGenerator","800px","500px","iframe",true,null,null,true);

	}
	
	parent._setDocEditorVal = setDocEditorVal;
	function setDocEditorVal(pKind){		
		return $("#Doc" + pKind + "Approval").val();
	}
	
	//조직도선택후처리관련
	parent._setDocEditor = setDocEditor;
	function setDocEditor(pKind,pData,pImages){		
		$("#Doc" + pKind + "Approval").val(pData);
		$("#Doc" + pKind + "ApprovalImages").val(pImages);
		$("#IsDoc" + pKind + "ApprovalEdit").val("Y");
	}
	function CheckInteger()
    {
        if (event.keyCode <= 45 || event.keyCode > 57 ) 
        {
            event.returnValue = false;
        }
    }
	
	/* 문서관리시스템 분류선택창 OPEN 시작 */
	function OpenDocClass() {
		var fdid = document.getElementById("DocClassID").value;
		var domainCode = $("#selectCompanyCode").val();
		var domainId = "";
		if(window.domainCodeMapping && window.domainCodeMapping[domainCode] != ""){
			domainId = window.domainCodeMapping[domainCode];
		}
		var isEdmsPopup = false;
		var gDocboxMenu = Common.getBaseConfig("DocboxMenu", domainId);
		if (gDocboxMenu == "F") {
	    	// EDMS 사용여부에 따라 문서관리 분류함 팝업을 선택. (선택된 스키마정보 기준)
	    	if(getSchemaContext("scEdmsLegacy.isUse") == "Y"){
	    		isEdmsPopup = true;	
	    	}
	    }	
		
		if(isEdmsPopup == true){
    		var sUrl = "/groupware/board/goSearchBoardTreePopup.do?bizSection=Doc&isEDMS=Y";// isEDMS 값에 따라 문서분류에서 승인프로세스 맵은 제외된다.
    		var _win = this;
    		var edmsPopupCallback = function(pFolderData){
    			_win.$("#DocClassID").val(pFolderData.FolderID);
    			_win.$("#DocClassName").val(pFolderData.DisplayName);
    		};
    		window._CallBackMethod = edmsPopupCallback;
    		CFN_OpenWindow(sUrl + "", "PopupEdmsClass", "360", "505", "fix");
		}else{
		    var EntDocObj = Base64.utf8_to_b64($("#EntDocClassID").val());
	        var sUrl = "/approval/manage/goDocClassEntPop.do?openID=div_OptionalSetting&OpenFrom=FormDocClassEntSet&EntDocObj="+EntDocObj;
	        var stitle = "<spring:message code='Cache.lbl_apv_docClassEntset' />"; //문서분류 계열사별 지정

	        parent.Common.open("","DocClassEntPop",stitle,sUrl,"500px","400px","iframe",true,null,null,true);
		}
	}
	
	function changeAclAllYn (){
		var aclAllYn = $("[name=AclAllYN]:checked").val();
		if("Y" == aclAllYn){
			$("#permissionBtnSpan").css("visibility","hidden");
		}else{
			$("#permissionBtnSpan").css("visibility","");
		}
	}
	
	function getSchemaContext(key) {
		//if(getSchemaContext("scEdmsLegacy.isUse") == "Y")
		var schema_Id = $("#selschema").val();
		if(!schema_Id) Common.Warning("<spring:message code='Cache.msg_apv_517' />"); // 양식프로세스를 선택해주세요
		var result = {};
		var __url = "/approval/manage/getschemainfo.do";
		$.ajax({
			url: __url,
			type:"POST",
			data:{
				"SCHEMA_ID" : schema_Id
			},
			async:false,
			success:function (data) {
				if(data.status == "SUCCESS"){
					result = data.data.map[0]["SCHEMA_CONTEXT"];
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(__url, response, status, error);
			}			
		});
		
		var obj = result;
		var keyNames = key.split(".");
		for(var idx in keyNames){
			obj = obj[keyNames[idx]];
			if((typeof obj) == "string") {
				break;
			}
		}
		var rtn = obj;
		return rtn == undefined ? "" : rtn;
	}
	
	function setEasyAdmFormat(){
		if($("#tr_UseEditYN").css("display").toLowerCase() == "none"){ // !$("#tr_UseEditYN").is(":visible") 탭구조이므로 불가
			$("#td_hidBodyDefault").attr("colspan","2");
		}
		if($("#tr_fmsk").css("display").toLowerCase() == "none"){
			$("#th_Desc_selclass").removeAttr("rowspan");
		}
	}
	
	//계열사별문서분류 후처리관련
	parent._CallBackDocClassMethod = fnRtnSetDocListInfo;
	function fnRtnSetDocListInfo(pdata){
	    var strClassName = "";
	    $(pdata).each(function (i, item) {
			strClassName += ((i>0) ? ", ": "") + item.EntName+":"+item.docClassName;
	    });
	    $("input[name=DocClassName]").val(strClassName);
	    $("input[name=EntDocClassID]").val(JSON.stringify(pdata));
	}
</script>