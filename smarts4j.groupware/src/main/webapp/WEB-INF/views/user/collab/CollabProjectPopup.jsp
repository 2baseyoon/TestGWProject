<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="el" uri="/WEB-INF/tlds/el-functons.tld"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	.ui-autocomplete-multiselect.ui-state-default{width:100% !important;border:0px}
	.ui-autocomplete-multiselect input{width:60px !important; border:0px !important}
	#subViewMember{border:0px;display: inline-block; vertical-align: middle; width:60px; height:30px; padding: 2px 0 0 10px;}
	.inputBoxContent > div:first-child {border-top:1px solid #969696 !important;}
</style>
<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js"></script>
<body>	
<div class="collabo_popup_wrap" id="collabo_popup_wrap">
<form id="form1">
	<div class="c_titBox">
		<h3 class="cycleTitle">
			<spring:message code='Cache.lbl_PrjOverView' /> <!-- 프로젝트 개요 -->
			<a class="btn_coStar ${prjData.IsFav=='0'?'':'active'}" style="cursor:default; display:none;" ><spring:message code='Cache.btn_Favorite'/></a>	<!-- 즐겨찾기 -->
		</h3>
	</div>
	<div class="collabo_table_wrap mb40">
		<table class="collabo_table projectName" cellpadding="0" cellspacing="0">
			<colgroup>
				<col width="106">
				<col width="200">
				<col width="106">
				<col width="*">
			</colgroup>
			<tbody>
				<tr>
					<th>
						<font color="red">*</font>
						<spring:message code='Cache.ACC_lbl_projectName'/>
					</th>
					<td colspan="3">
						<input type="text" class="w100 HtmlCheckXSS ScriptCheckXSS Required SpecialCheck MaxSizeCheck" max="50" id="prjName" value="${prjData.PrjName }" title="<spring:message code='Cache.ACC_lbl_projectName'/>"/>
						<c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">
						</c:if>
					</td>
				</tr>	
			</tbody>
		</table>
				
		<div class="collabo_method">
			<div class="c_titBox">
				<h3 class="cycleTitle"><spring:message code='Cache.lbl_ProjectCollabInfo'/>
					<div class="collabo_help02">
						<a href="#" class="help_ico" id="btn_info"></a>
					</div>
				</h3>	<!-- 프로젝트 협업방식 안내 -->
			</div>
			<textarea id="remark" cols="30" rows="10" placeholder="<spring:message code='Cache.lbl_ProjectMsg1'/>">${prjData.Remark}</textarea>
		</div>
		
		
		<ul class="tabMenu clearFloat">
			<li class="active"><a href="#"><spring:message code='Cache.btn_Role'/></a></li>	<!-- 역할 -->
			<li class=""><a href="#"><spring:message code='Cache.btn_Data'/></a></li>	<!-- 자료 -->
			<li class=""><a href="#"><spring:message code='Cache.btn_ExtendedField'/></a></li>	<!-- 확장필드 -->
			<c:if test="${fn:length(sectionList) > 0 }">
			<li class=""><a href="#"><spring:message code='Cache.btn_milestone'/></a></li>	<!-- 마일스톤 -->
			</c:if>
		</ul>
		<div class="tabContent active">
			<div class="c_titBox">
				<h3 class="cycleTitle"><spring:message code='Cache.lbl_ProjectRole'/>
					<div class="collabo_help02">
						<a href="#" class="help_ico" id="btn_role"></a>
					</div>
				</h3>	<!-- 프로젝트 역활 -->
			</div>	
			<div class="collabo_table_wrap mb40">
				<table class="collabo_table" cellpadding="0" cellspacing="0">
					<colgroup>
						<col width="106">
						<col width="*">
						<col width="106">
						<col width="*">
					</colgroup>
					<tbody>
					<tr>
					 	<th><font color="red">*</font> <spring:message code='Cache.lbl_Period' /></th>	<!-- 기간 -->
						<Td colspan=3>
						    <span class="dateSel type02">
								<input class="adDate Required" type="text" id="startDate" date_separator="." readonly="" value="${prjData.StartDate}" title="<spring:message code='Cache.lbl_start_date'/>"> - 
								<input id="endDate" date_separator="." date_startTargetID="startDate" class="adDate  Required" type="text" readonly="" value="${prjData.EndDate}" title="<spring:message code='Cache.lbl_end_date'/>">
							</span>											
						</Td>
					 </tr>
					<tr>
						<th><font color="red">*</font> <spring:message code='Cache.CPMail_Status'/></th>
						<td colspan=3>
							<div class="chkStyle10">
								<input type="checkbox" class="check_class" id="chk_w" value="W" ${prjData.PrjStatus=='W'?'checked':'' }>
								<label for="chk_w"><span class="s_check"></span><spring:message code='Cache.lbl_Ready' /></label> <!-- 대기 -->
							</div>	
							<div class="chkStyle10">
								<input type="checkbox" class="check_class" id="chk_p" value="P" ${prjData == null or prjData.PrjStatus=='P'?'checked':'' }>
								<label for="chk_p"><span class="s_check"></span><spring:message code='Cache.lbl_Progress' /></label> <!-- 진행 -->
							</div>	
							<div class="chkStyle10">
								<input type="checkbox" class="check_class" id="chk_h" value="H" ${prjData.PrjStatus=='H'?'checked':'' }>
								<label for="chk_h"><span class="s_check"></span><spring:message code='Cache.lbl_Hold' /></label> <!-- 보류 -->
							</div>	
							<div class="chkStyle10">
								<input type="checkbox" class="check_class" id="chk_f" value="F" ${prjData.PrjStatus=='F'?'checked':'' }>
								<label for="chk_f"><span class="s_check"></span><spring:message code='Cache.lbl_Cancel' /></label> <!-- 취소 -->
							</div>	
							<div class="chkStyle10">
								<input type="checkbox" class="check_class" id="chk_c" value="C" ${prjData.PrjStatus=='C'?'checked':'' }>
								<label for="chk_c"><span class="s_check"></span><spring:message code='Cache.lbl_Completed' /></label> <!-- 완료 -->
							</div>	
						</td>
					</tr>
					 <tr>
						<th><font color="red">*</font> <spring:message code='Cache.lbl_TFProgressing'/></th>
						<td><input type="text" class="w100 Required Number right" id="progRate" title="<spring:message code='Cache.lbl_TFProgressing'/>" value="${(prjData =='' || prjData.PrjSeq eq null )?0:prjData.ProgRate }" title="<spring:message code='Cache.lbl_TFProgressing'/>"/></td>
						<th><spring:message code='Cache.ThemeType_BgColor'/></th>
						<td>
							<div id="colorPicker" style="float:left"></div>
						</td>
					</tr>
					<tr>
					 	<th><spring:message code='Cache.lbl_apv_Admin' /></th>
						<Td colspan="3">
							<div class="org_T">
								<div class="org_T_l">
									<div class="org_list_box mScrollV scrollVType01 mCustomScrollbar"  id="resultViewManager" style="height:100%;min-height:50px;">
									<input id="resultViewManagerInput" type="text" class="HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
									</div>	
								</div>
								<c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">
									<div class="org_T_r">
										<a class="btnTypeDefault nonHover type01" id="btnManager"><spring:message code='Cache.btn_OrgManage' /></a>
									</div>	
								</c:if>	
							</div>	
						</Td>
					</tr>
					<tr>
					 	<th><spring:message code='Cache.lbl_Res_Admin' /></span></th>
						<Td colspan=3>
							<div class="org_T">
								<div class="org_T_l" id="res_admin">
									<div class="org_list_box mScrollV scrollVType01 mCustomScrollbar"  id="resultViewMember" style="height:100%;min-height:50px;">
									<input id="resultViewMemberInput" type="text" class="HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
									</div>	
								</div>
								<c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">
									<div class="org_T_r">
										<a class="btnTypeDefault nonHover type01" id="btnMember"><spring:message code='Cache.btn_OrgManage' /></a>
									</div>	
								</c:if>	
							</div>	
						</Td>
					 </tr>
					 <c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">
					 <tr>
					 	<th><spring:message code='Cache.btn_Viewer' /></span></th>
						<Td colspan=3>
							<div class="org_T">
								<div class="org_T_l">
									<div class="org_list_box mScrollV scrollVType01 mCustomScrollbar"  id="resultViewViewer" style="height:100%;min-height:50px;">
									<input id="resultViewViewerInput" type="text" class="HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
									</div>	
								</div>
								<div class="org_T_r">
									<a class="btnTypeDefault nonHover type01" id="btnViewer"><spring:message code='Cache.btn_OrgManage' /></a>
								</div>	
							</div>	
						</Td>
					 </tr>
					</c:if>	
					<c:if test="${prjData !='' && prjData.PrjSeq ne null }">
					<tr>
						<th><spring:message code='Cache.lbl_Register'/></th>
						<td colspan="3">${prjData.RegisterName}
						</td>
					</tr>
					</c:if>
					</tbody>
				</table>
			</div>
		</div>
		<div class="tabContent">
			<div class="c_titBox">
				<h3 class="cycleTitle"><spring:message code='Cache.btn_Data'/></h3>	<!-- 자료 -->
			</div>
			<div class="inputBoxContent">
				<%if (RedisDataUtil.getBaseConfig("isUseCollabApproval").equals("Y") ){%>
				 <c:if test="${prjAdmin =='Y'}">
				<div class="inputBoxSytel01 type02" style="padding-top:10px;padding-bottom:10px">
						<div><span><spring:message code='Cache.lbl_att_approvalForm'/></span></div>
						<div>
							<input type="text" value="" class="connect_approval">
							<a href="#" class="btnTypeDefault" onclick="collabUtil.openApprovalListPopup('${prjData.PrjSeq}','PROJECT');"><spring:message code='Cache.lbl_Browse'/></a>	<!-- 찾아보기 -->
						</div>
				</div>	
				</c:if>	
				<%}%>
				<div class="inputBoxSytel01 type02" style="border-bottom:solid 1px #969696;">
					<div style="vertical-align:middle;"><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>	<!-- 파일 첨부 -->
					<div id="con_file">
						<c:if test="${prjAdmin !='Y'}">
						<c:if test ="${fn:length(fileList) > 0}">
							<div>
								<ul class="fileUpview fileview" ${(prjAdmin =='Y' || prjData.PrjSeq eq null )? "":"style='max-height:200px'"}>
								<c:forEach items="${fileList}" var="list" varStatus="status">
									<c:set var="selValue" value="${el:getImageFilePath(list.FileID, list.FilePath, list.SavedName)}" />
									<li>
									<div class="" data-fileid="${list.FileID }" data-filetoken="${list.FileToken}" data-fileext="${list.Extention}">
										<a class="btn_dfile">
											<script>var icon = collabUtil.getFileClass("${list.Extention}");
													document.write("<span class='file_down "+icon+"'></span>");
											</script>
											${list.FileName}
											<span class="file_prev btn_dsearch" onclick=""></span>
										</a>
									</div>
									</li>
								</c:forEach>
								</ul>
							</div>
						</c:if>
						<c:if test="${prjData.PrjSeq ne null && fn:length(fileList) == 0}">
							<div id="divFileList" style="text-align:center;height:100px;line-height:100px;">등록된 자료가 없습니다.</div>						
						</c:if>
						</c:if>
					</div>
				</div>
			</div>
		</div>
		<div class="tabContent">	
			<div class="c_titBox">
				<h3 class="cycleTitle"><spring:message code='Cache.btn_ExtendedField' /></h3> <!-- 확장필드 -->
				<c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">
					<div class="control_box">
						<a href="#" class="btn_minus" data-type="extend"><spring:message code='Cache.btn_delete' /></a> <!-- 삭제 -->
						<a href="#" class="btn_plus" data-type="extend"><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
					</div>
				</c:if>	
			</div>
			<div class="tblList tblCont boradBottomCont StateTb">
				<table class="WorkingStatus_table" id="tblUserForm" cellpadding="0" cellspacing="0">
					<colgroup>
						<col width="46">
						<col width="180">
						<col width="100">
						<col width="*">
					</colgroup>
					<thead>
						<tr>
							<th><input id="allChk"  type="checkbox" data-type="extend" /></th>
							<th><spring:message code='Cache.lbl_ItemName' /></th>	<!-- 항목명 -->
							<th><spring:message code='Cache.lbl_type' /></th>	<!-- 항목명 -->
							<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 내용 -->
						</tr>
					</thead>
					<tbody>
						<c:forEach items="${userformList}" var="list" varStatus="status">
							<tr>
								<td><input type="checkbox"  data-type="extend" /></td>
								<td><input type=text class="txtTitle textArea" readonly value="${list.OptionTitle}"></td>
								<Td><input type=text class="txtType textArea" readonly value="${list.OptionType}"></td>
								<td><input type=text class="txtVal textArea"  readonly value="${list.OptionVal}"></td>
							</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>	
		</div>
		<div class="tabContent">
			<div class="c_titBox">
				<h3 class="cycleTitle"><spring:message code='Cache.btn_milestone'/>
					<div class="collabo_help02">
						<a href="#" class="help_ico" id="btn_mile"></a>
					</div>
				</h3>	<!-- 마일스톤 -->
				<div class="control_box">
					<a href="#" class="btn_remove" data-type="mile"><spring:message code='Cache.btn_delete'/></a>	<!-- 삭제 -->
					<a href="#" class="btn_plus" data-type="mile"><spring:message code='Cache.btn_Add'/></a>	<!-- 추가 -->
				</div>
			</div>
			<!-- 마일스톤 영역 -->
			<div style="border-top:solid 1px #969696;border-bottom:solid 1px #969696; padding:10px 0 0 0;">
			<ul class="milestoneList" id="mileForm"></ul>
			<div id="divEmptyMileStone" style="text-align:center;height:100px;line-height:100px;<c:if test="${fn:length(mileList) > 0 }">display:none;</c:if>">등록된 마일스톤이 없습니다.</div>
			<ul class="milestoneList" id="mileList">
			
			<c:forEach items="${mileList}" var="list" varStatus="status">
				<li class="">
					<div class="milestone">
						<input type="checkbox" id="chk_${list.TaskSeq}" ${list.TaskStatus=='C'?'checked':''} data-taskSeq="${list.TaskSeq}"><label for="chk_${list.TaskSeq}"><span class="ms_check"></span></label> <!--완료하기  -->
					</div>
					<input type="text" id="taskname_${list.TaskSeq}" value="${list.TaskName}" readonly="readonly"/>
					<p class="selectSection" style="text-overflow:ellipsis;overflow:hidden;white-space:nowrap">
						<a class="btnSecChg" data-taskSeq="${list.TaskSeq}" data-seq="${list.SectionSeq}" data-name="${list.SectionName}">
							<c:if test="${(list.SectionName eq 'hold')}"><spring:message code='Cache.btn_SectionChange'/></c:if>	<!-- 섹션변경 -->
							<c:if test="${(list.SectionName ne 'hold')}">${list.SectionName}</c:if>
						</a>
					</p>
					<div class="dateSel type02">
						<input class="adDate" id="date_${list.TaskSeq}" type="text" value="" readonly="readonly"/>
						
						<c:if test="${(list.EndDate !='' && list.EndDate ne null)}">
							<script>
								$("#date_${list.TaskSeq}").val("${fn:substring(list.EndDate,0,4)}.${fn:substring(list.EndDate,4,6)}.${fn:substring(list.EndDate,6,8)}");
							</script>
						</c:if>
					</div>
					
				<c:if test="${list.tmUser !='' && list.tmUser ne null}">
					<div id="sub_${list.TaskSeq}" style="display: inline-block; overflow: hidden; vertical-align: middle; width:50px; height:30px; padding: 2px 0 0 10px; background-color:#f4f4f; border:0;"></div>
					
					<c:set var="users" value="${fn:split(list.tmUser,'|')}" />
					
					<c:forEach var="sub" items="${users}" varStatus="status">
						<c:if test="${status.index eq 0}">
							<script>
							var userDetailArr = "${sub}".split('^');
							$("#sub_${list.TaskSeq}").append(collabUtil.drawProfileOne({"code":userDetailArr[0],"DisplayName":userDetailArr[1],"PhotoPath":userDetailArr[2],"DeptName":userDetailArr[3], "personCnt":"${fn:length(users)}"}, false)); </script>
						</c:if>	
					</c:forEach>
				</c:if>
				
					<a class="msEdit" data-taskSeq="${list.TaskSeq}" data-sectionSeq="${list.SectionSeq}" data-sectionName="${list.SectionName}"><spring:message code='Cache.btn_Modify'/></a>	<!-- 수정 -->
					<a class="msDel" data-taskSeq="${list.TaskSeq}"><spring:message code='Cache.btn_delete'/></a>	<!-- 삭제 -->
					<a class="msDetail" data-taskSeq="${list.TaskSeq}"><spring:message code='Cache.lbl_DetailView1'/></a>	<!-- 자세히보기 -->
					
				</li>
			</c:forEach>
				
			</ul>
			</div>
		</div>

				
		<c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">	
			<div class="popBtnWrap">
				<c:if test="${prjData =='' || prjData.PrjSeq eq null  }">
					<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.lbl_AddProject'/></a>
				</c:if>
				<c:if test="${prjData !='' && prjData.PrjSeq ne null  }">
					<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_SaveProject'/></a>
				</c:if>
				
				<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code="Cache.lbl_Cancel"/></a>
			</div>
		</c:if>	
	</div>	
</form>				
</div>

</body>
</html>

<script type="text/javascript">

var memberList = new Array();
var sectionList = new Array();

var collabProjectAdd = {
		fileList:'',
		objectInit : function(){
			this.addEvent();
			<c:forEach items="${memberList}" var="list" varStatus="status">
				$("#resultViewMember input").before(collabUtil.drawProfile({"type":"UR","code":"${list.UserCode}","PhotoPath":"${list.PhotoPath}","DisplayName":"${list.DisplayName}","DeptName":"${list.DeptName}","UserID":"${list.UserID}","ETNM":"${list.ETNM}","TL":"${list.TL}","PO":"${list.PO}","LV":"${list.LV}"}
				, ${prjAdmin =='Y'?"true":"false"}, "memeber")); 
				
				var dataObj = new Object();
				dataObj = {"type":"UR","code":"${list.UserCode}","PhotoPath":"${list.PhotoPath}","DisplayName":"${list.DisplayName}","DeptName":"${list.DeptName}","UserID":"${list.UserID}"};
				memberList.push(dataObj);
			</c:forEach>
			<c:forEach items="${managerList}" var="list" varStatus="status">
				$("#resultViewManager input").before(collabUtil.drawProfile({"type":"UR","code":"${list.UserCode}","PhotoPath":"${list.PhotoPath}","DisplayName":"${list.DisplayName}","DeptName":"${list.DeptName}","UserID":"${list.UserID}","ETNM":"${list.ETNM}","TL":"${list.TL}","PO":"${list.PO}","LV":"${list.LV}"}
				, ${prjAdmin =='Y'?"true":"false"}, "manager")); 
			</c:forEach>
			<c:forEach items="${viewerList}" var="list" varStatus="status">
				$("#resultViewViewer input").before(collabUtil.drawProfile({"type":"UR","code":"${list.UserCode}","PhotoPath":"${list.PhotoPath}","DisplayName":"${list.DisplayName}","DeptName":"${list.DeptName}","UserID":"${list.UserID}","ETNM":"${list.ETNM}","TL":"${list.TL}","PO":"${list.PO}","LV":"${list.LV}"}
				, ${prjAdmin =='Y'?"true":"false"}, "viewer")); 
			</c:forEach>
			
			<c:if test="${prjAdmin !='Y' && (prjData !='' && prjData.PrjSeq ne null )}">	 
				$("input").attr('readonly', true).css({"border-style":"none","background-color":"#fff"});
				$("textarea").attr('readonly', true);
				$("input[type=checkbox]").attr('disabled', true);
				
				$(".milestoneList").find("input").css({"background-color":"#f4f4f4"});
				$(".control_box").hide();
				$(".milestone input[type=checkbox]").off("click");
				$(".btnSecChg").off("click");
				$(".msEdit").hide();
				$(".msDel").hide();
				
			</c:if>
			
			<c:if test="${fn:length(sectionList) > 0 }">
				<c:forEach items="${sectionList}" var="item" varStatus="status">
					var dataObj = new Object();
					dataObj = {"sectionSeq":"${item.SectionSeq}","sectionName":"${item.SectionName}"};
				
					sectionList.push(dataObj);
				</c:forEach>
			</c:if>
			
			$("#resultViewManager > div").attr("style", "");
			$("#resultViewMember > div").attr("style", "");
			$("#resultViewViewer > div").attr("style", "");

			<c:if test="${prjAdmin != 'Y' && (prjData != '' && prjData.PrjSeq ne null )}">
				$("#resultViewManagerInput").hide();
				$("#resultViewMemberInput").hide();
				$("#resultViewViewerInput").hide();

				$("#btn_info").parent().hide();
				$("#btn_role").parent().hide();
				$("#btn_mile").parent().hide();
				
				$("span.s_check").attr("style", "cursor:default;");
				
				$("#remark").removeAttr("placeholder");
			</c:if>
			
		}	,
		addEvent : function(){
			
			<c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">
				$("#endDate").bindTwinDate({
					startTargetID : "startDate",
					separator : ".",
					onchange: function(dateText){
						$("#startDate").val(this["ST_value"]);
						$("#endDate").val(this["ED_value"]);
					}
				});
			</c:if>
			
			//툴팁
			Common.toolTip($("#btn_info"), Array("collabProject1","collabProject2","collabProject3"));
			Common.toolTip($("#btn_role"), Array("collabProject4","collabProject5","collabProject6"));
			Common.toolTip($("#btn_mile"), Array("collabProject7","collabProject8","collabProject9"));
			
			//탭
			$(".tabMenu li").on('click',function(){
				$(".tabMenu li").removeClass("active");
				$(".tabMenu li").eq($(this).index()).addClass("active");
				
				$(".tabContent").removeClass("active");
				$(".tabContent").eq($(this).index()).addClass("active");
				
			});
			
			/*즐겨찾기
			$("#btnFav").on( 'click',function(){
				collabUtil.btnFavEvent('collabo_popup_wrap', CFN_GetQueryString("prjSeq"), this);
			});
			*/
			var colorList = Common.getBaseCode("ScheduleColor");
			var dataPalette = new Array();
			var defaultColor = "${prjData.PrjColor}";//"#" + CFN_GetQueryString("defaultColor");
			//;color:${prjData.PrjColor}
			
			<c:if test="${prjAdmin != 'Y' && (prjData != '' && prjData.PrjSeq ne null )}">
			$("#progRate").removeClass("right");
			//$("#progRate").attr("class", "w100 Required Number");
			$("#colorPicker").append('<div class="palette-color-picker-button" data-target="colorPicker" style="background:' + defaultColor + ';cursor: auto;"></div>');
			</c:if>
			<c:if test="${prjAdmin == 'Y' || (prjData =='' || prjData.PrjSeq eq null )}">
			if (defaultColor != ''){
				dataPalette.push({"default" : defaultColor});
			}
			
			$(colorList.CacheData).each(function(){
				var obj = {};
				$$(obj).append(this.Code, "#"+this.Code);
				
				dataPalette.push(obj);
			});
			
			coviCtrl.renderColorPicker("colorPicker", dataPalette, 'N');
			$('.palette-color-picker-bubble').attr("style","z-index:99");
			</c:if>
			
			<c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">
				collabUtil.attachEventAutoTags("resultViewMemberInput");
				collabUtil.attachEventAutoTags("resultViewManagerInput");
				collabUtil.attachEventAutoTags("resultViewViewerInput");
				<c:if test="${fileList ne null}">
				collabProjectAdd.fileList= JSON.parse('${fileList}');
				</c:if>
				coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true', image : 'false'}, collabProjectAdd.fileList);	
			</c:if>
			
			$(document).on('click', '.file_down', function(e) {
				Common.fileDownLoad($(this).closest("div").data("fileid"), $(this).closest("div").text(), $(this).closest("div").data("filetoken"));//data-fileext
				e.stopPropagation(); // 부모 호출 안되도록 처리
			});
			$(document).on('click', '.btn_dfile', function (e) {
				Common.fileDownLoad($(this).closest("div").data("fileid"), $(this).closest("div").text(), $(this).closest("div").data("filetoken"));//data-fileext
			});
			$(document).on('click', '.file_prev', function(e) {
				Common.filePreview($(this).closest("div").data("fileid"), $(this).closest("div").data("filetoken"),$(this).closest("div").data("fileext"));
				e.stopPropagation(); // 부모 호출 안되도록 처리
			});
			//file 삭제
			$(document).on('click', '.file_del', function(e) {
				var obj = this;
				$.ajax({
					type:"POST",
					data: {"taskSeq": CFN_GetQueryString("taskSeq"),"fileID":$(this).parent().data("fileid")},
					url:"/groupware/collabTask/deleteTaskFile.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");	//ë³µì¬ëììµëë¤.
							$(obj).closest("li").remove();
						}
						else{
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	ì¤ë¥ê° ë°ìíìµëë¤. ê´ë¦¬ììê² ë¬¸ìë°ëëë¤
						}
					},
					error:function (request,status,error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
				
			});
			
			//즐겨찾기
			$("#btnFav").on( 'click',function(e){
				$.ajax({
            		type:"POST",
            		data:{"prjSeq":  CFN_GetQueryString("prjSeq"), "isFlag":$(this).hasClass("active")},
            		url:"/groupware/collabProject/saveProjectFavorite.do",
            		success:function (data) {
            			if(data.status == "SUCCESS"){
            				$("#btnFav").toggleClass("active");
            				
            				parent.collabMenu.getUserMenu();
            			}
            			else{
            				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
            			}
            		},
            		error:function (request,status,error){
            			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
            		}
            	});
			});
			
			//담당자 추가
			$("#btnMember").on('click', function(){
				collabProjectAdd.openOrgMapLayerPopup('orgMemberCallback','resultViewMember');
			});
			//관리자 추가
			$("#btnManager").on('click', function(){
				collabProjectAdd.openOrgMapLayerPopup('orgManagerCallback','resultViewManager');
			});
			//조회사추가
			$("#btnViewer").on('click', function(){
				collabProjectAdd.openOrgMapLayerPopup('orgViewerCallback','resultViewViewer');
			});
			
			//저장
			$("#btnSave").on('click', function(){
				if(!collabProjectAdd.validationChk())     	return ;
				Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var prjData = collabProjectAdd.getProjectData();
						prjData.append("prjSeq", "${prjData.PrjSeq}");
						prjData.append("PrjType", "${prjData.PrjType}");
						
						$.ajax({
							type:"POST",
							enctype: 'multipart/form-data',
							processData: false,
							contentType: false,
							data:prjData,
							url:"/groupware/collabProject/saveProject.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>", "Confirmation Dialog", function (confirmResult) {
										Common.Close();
									});	
									
									parent.collabMenu.getUserMenu();	// 좌측메뉴 새로고침
								}
								else{
									if (data.exception.indexOf("MultipartException")>-1){
										Common.Error("<spring:message code='Cache.msg_ExistLimitedExtensionFile' />"); //	파일 ulload
									}else{
										Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
									}	
								}
							},
							error:function (request,status,error){
								
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					}
				});	
			});	
			
			//추가
			$("#btnAdd").on('click', function(){
				if(!collabProjectAdd.validationChk())     	return ;
				Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var prjData = collabProjectAdd.getProjectData();
						
						$.ajax({
							type:"POST",
							enctype: 'multipart/form-data',
							processData: false,
							contentType: false,
							data:prjData,
							url:"/groupware/collabProject/addProject.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");	//복사되었습니다.
									parent.collabMenu.getUserMenu();
									Common.Close();
								}
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					}
				});	
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
			
			$(".check_class").on('click', function(){
				 $('.check_class').not(this).prop("checked", false);
			});
			
			$("#allChk").on('click', function(){
				$('#tblUserForm > tbody input[type="checkbox"]').prop("checked",$(this).is(":checked"));
			});
			
			//마일스톤 이벤트
			collabProjectAdd.milestoneEvent();
			
			//마일스톤 입력폼 삭제
			$(".btn_remove").on('click', function(e){
				e.preventDefault();
				$(".milestoneAdd").remove();
				
				if ($("#mileList").find("li").length == 0) {
					$("#divEmptyMileStone").show();
				}
			});
			
			//마일스톤,확장필드 추가
			$(".btn_plus").on('click', function(e){
				e.preventDefault();
				var dataType = $(this).data();
				
				if(dataType.type == "mile"){	//마일스톤
					
					if ($(".milestoneAdd").length>0){
						if ($(".milestoneAdd").find("#subTaskName").val() != "") {
							parent.Common.Error("<spring:message code='Cache.msg_JobNotRegistered' />", "", function () { //등록 안 된 업무가 있습니다.
								$(".milestoneAdd").find("#subTaskName").focus();
							});
						}
						else{
							$(".milestoneAdd").find("#subTaskName").focus();
						}
						return;
					}
					
					var drawAddTask = $("<li>",{ "class" : "milestoneAdd"})
					.append($("<div>",{ "class" : "milestone"})
						.append($("<input>",{"type":"checkbox","id":"chk11","class":"list_chk"}))
						.append($("<label>",{"for":"chk11"})
							.append($("<span>",{"class":"ms_check"}))))
					.append($("<input>",{"type":"text","id":"subTaskName", "placeholder":Common.getDic("msg_TaskAndPress"), "max":"50", "maxlength":"50"}))
					
				<c:if test="${fn:length(sectionList) > 0 }">
					.append($("<select>",{"class":"selectType02", "id":"sectionSelect"})		//섹션
					<c:forEach items="${sectionList}" var="item" varStatus="status">
						.append($("<option>",{"value":"${item.SectionSeq}","text":"${item.SectionName}"}))
					</c:forEach>
					)
				</c:if>
					
					.append($("<div>",{"class":"dateSel type02"})
						.append($("<input>",{"class":"adDate","id":"subEndDate","value":CFN_GetLocalCurrentDate("yyyy.MM.dd")})))
					.append($("<div>",{"class":"org_list_box","id":"subViewMember"}))
					.append($("<a>",{"class":"btnTypeDefault search btn_list_icon02","text":"검색"}))
					;
					$("#divEmptyMileStone").hide();
					$('#mileForm').append(drawAddTask).find("#subTaskName").focus();
					
					$('#subEndDate').attr("style","width:86px;");
					$('#subEndDate').datepicker({
						dateFormat: 'yy.mm.dd',
					    showOn: 'button',
					    buttonText : 'calendar',
					    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/common/ic_cal.png", 
		                buttonImageOnly: true
					});
					
					//담당자 추가
					$(".btn_list_icon02").on('click', function(){
						var userCodes = "";
						$.each(memberList, function (i, v) {
							if(i > 0) userCodes = userCodes + ",";
							userCodes = userCodes + v.code;
						});
						
						if(userCodes == "") {
							Common.Inform("<spring:message code='Cache.msg_collab1' />");	//프로젝트에 지정된 담당자가 없습니다.
							return;
						}
						
						var popupID	= "CollabProjectInvitePopup";
						var popupTit	= Common.getDic("TodoMsgType_Invited");	//초대
						var callBack	= "callbackInvite";
						var popupUrl	= "/groupware/collab/CollabTargetTagListPopup.do?"
										+ "&userCodes=" 		+ encodeURIComponent(userCodes)
										+ "&callback=callbackOrgMember"	;
										
						Common.open("", popupID, popupTit, popupUrl, "550px", "650px", "iframe", true, null, null, true);
					});
					
					//담당자 변경 팝업
					$('#subViewMember').on('click', function(){
						
						var popupID = "CollabProfilePopup";
						var popupTit = "[<spring:message code='Cache.lbl_Collab' />]<spring:message code='Cache.lbl_apv_change_Charger' />";	//[협업스페이스] 담당자변경
						var popupYN		= "N";
						var callBack	= "";
						var popupUrl	= "/groupware/collab/CollabProfileTagListPopup.do?"
							+ "&popupID="		+ popupID
							+ "&popupYN="		+ popupYN
							+ "&callBackFunc="	+ callBack	;

						Common.open("", popupID, popupTit, popupUrl, "380", "200", "iframe", true, null, null, true);
					});
					
					//저장
					$('#subTaskName').on('keydown', function(key){
						 if (key.keyCode == 13) {
							 
								var sectionSeqSelect = ($("#sectionSelect").val() != undefined) ? $("#sectionSelect").val() : "";
								var sectionNameSelect = "";
								
								if(sectionSeqSelect != ""){
									for (var i = 0; i < sectionList.length; i++) {
										if(sectionList[i].sectionSeq == sectionSeqSelect)
											sectionNameSelect = sectionList[i].sectionName;
									}
								}

								// 완료여부
								var bIsComplate = $(this).parent().find("INPUT[type='checkbox']").is(":checked");
								
				                $.ajax({
				            		type:"POST",
				            		contentType:'application/json; charset=utf-8',
									dataType   : 'json',
				            		data:JSON.stringify({"taskSeq": "0",
				            			   "topTaskSeq": "0",
				            				"taskName":  $(this).val(),            				
				            				"startDate": $("#subEndDate").val(),
				            				"endDate": $("#subEndDate").val(),
				            				"trgMember":collabUtil.getUserArray("subViewMember"),
				            				"isMile": "Y",
				            				"prjSeq": "${prjData.PrjSeq }",
				            				"prjType": "${prjData.PrjType }",
				            				"sectionSeq": sectionSeqSelect
				            		}),	
				            		url:"/groupware/collabTask/addSubTaskSimple.do",
				            		success:function (data) {
				            			var drawAddTask = $("<li>",{ "class" : ""})
										.append($("<div>",{ "class" : "milestone"})
											.append($("<input>",{"type":"checkbox","id":"chk_"+data.TaskSeq,"class":"list_chk","data-taskSeq":data.TaskSeq}))
											.append($("<label>",{"for":"chk_"+data.TaskSeq+""})
												.append($("<span>",{"class":"ms_check"}))))
										.append($("<input>",{"type":"text","id":"taskname_"+data.TaskSeq,"value":data.TaskName, "readonly":"readonly"}))
										.append($("<p>",{"class":"selectSection","style":"text-overflow:ellipsis;overflow:hidden;white-space:nowrap;"})		//섹션
											.append($("<a>",{"class":"btnSecChg","data-taskSeq":data.TaskSeq,"data-seq":data.sectionSeq,"data-name":((sectionSeqSelect == '')?'hold':sectionNameSelect)})
												.append((sectionSeqSelect == '')?"<spring:message code='Cache.btn_SectionChange'/>":sectionNameSelect)))	//섹션변경
										.append($("<div>",{"class":"dateSel type02"})
											.append($("<input>",{"class":"adDate","type":"text","id":"date_"+data.TaskSeq,"value":$("#subEndDate").val(), "readonly":"readonly"})))
										.append($("<div>",{"id":"sub_"+data.TaskSeq,"style":"display: inline-block; overflow: hidden; vertical-align: middle; width:50px; height:30px; padding: 2px 0 0 10px; background-color:#f4f4f; border:0;"})
												.append($('#subViewMember').html()))
										.append($("<a>",{"class":"msEdit","data-taskSeq":data.TaskSeq,"data-sectionSeq":data.SectionSeq,"data-sectionName":data.SectionName,"text":"<spring:message code='Cache.btn_Modify'/>"}))	//수정
										.append($("<a>",{"class":"msDel","data-taskSeq":data.TaskSeq,"text":"<spring:message code='Cache.btn_delete'/>"}))	//삭제
										.append($("<a>",{"class":"msDetail","data-taskSeq":data.TaskSeq,"text":"<spring:message code='Cache.lbl_DetailView1'/>"}))	//자세히보기
										;
				            			
				            			//마일스톤 목록에 추가
				   						$('#mileList').append(drawAddTask);
				   						
				   						//마일스톤 이벤트
				   						collabProjectAdd.milestoneEvent();
				            			
				            			//마일스톤 입력창 삭제
				            			$(".milestoneAdd").remove();

				            			if (bIsComplate){
											var	oData={"taskSeq": data.TaskSeq, "taskStatus": bIsComplate};
											collabUtil.saveTaskComplete(oData, function (res) {
						   						$('#mileList').find("INPUT[type='checkbox'][data-taskSeq='" + data.TaskSeq + "']").prop("checked", true);
											});
				            			}
				            		},
				            		error:function (request,status,error){
				            			parent.Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				            		}
				            	});
				                
				            }
				        });
					
					
				}else if(dataType.type == "extend"){	//확장필드
					if ($('#tblUserForm tbody tr').length < 11){
						 $('#tblUserForm > tbody:last').append('<tr>'+
								 '<td><input type=checkbox></td>'+
								 '<td><input type=text class="txtTitle"></td>'+
								 '<td><select class="txtType" readonly>'+
								 '  <option value=Input>Input</option>'+
								 '	<option value=TextArea>TextArea</option>'+
								 '	<option value=Date>Date</option>'+
								 '</select></td>'+
								 '<td><input type=text class="txtVal"></td>'+
							'</tr>');
						 
						 $('#tblUserForm tbody tr td select').change('on', function() {
						 	if($(this).val() == "Date") {
						 		$(this).parent().parent().children('td').eq(3).children('input').hide();
						 	} else {
						 		$(this).parent().parent().children('td').eq(3).children('input').show();
						 	}
						 });
					}
				}
			});
			
			//확장필드 삭제
			$(".btn_minus").on('click', function(e){
				e.preventDefault();
		
				if($('#tblUserForm > tbody input[type="checkbox"]:checked').size() < 1)				
					Common.Inform("<spring:message code='Cache.msg_Common_03' />");	//삭제할 항목을 선택하여 주십시오.
					
				$('#tblUserForm > tbody input[type="checkbox"]:checked').each(function (i, v) {
					$(v).parents("tr").remove();
				});
			});
			
			//사용자나 부서/ 일자 삭제
			$(document).on('click', '.btn_del', function(e) {
				e.preventDefault();
				$(this).parent().remove();
			});
			
			var observerMem = new MutationObserver(function(mutations) {
				var duplication = false;
				var code = $("#resultViewMember .user_img").last().attr("code");
				var type = $("#resultViewMember .user_img").last().attr("type");
				
				if ($('#resultViewMember').find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 1) {
					duplication = true;
				}
				
				if (duplication) {
					Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
					$("#resultViewMember .user_img").last().remove();
				}
			});
			var observerMan = new MutationObserver(function(mutations) {
				var duplication = false;
				var code = $("#resultViewManager .user_img").last().attr("code");
				var type = $("#resultViewManager .user_img").last().attr("type");
				
				if ($('#resultViewManager').find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 1) {
					duplication = true;
				}
				
				if (duplication) {
					Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
					$("#resultViewManager .user_img").last().remove();
				}
			});
			var observerViw = new MutationObserver(function(mutations) {
				var duplication = false;
				var code = $("#resultViewViewer .user_img").last().attr("code");
				var type = $("#resultViewViewer .user_img").last().attr("type");
				
				if ($('#resultViewViewer').find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 1) {
					duplication = true;
				}
				
				if (duplication) {
					Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
					$("#resultViewViewer .user_img").last().remove();
				}
			});
			var optionObserver = {
			    childList: true,
			    subtree : true
			};

			observerMem.observe($("#resultViewMember")[0], optionObserver);
			observerMan.observe($("#resultViewManager")[0], optionObserver);
			<c:if test="${prjAdmin =='Y' || (prjData =='' || prjData.PrjSeq eq null )}">
			observerViw.observe($("#resultViewViewer")[0], optionObserver);
			</c:if>
		},
		milestoneEvent:function(){
			//업무 상세
			$(".msDetail").on('click', function(){
				parent.collabUtil.openTaskPopup("CollabTaskPopup", "CollabTaskPopup", $(this).data("taskseq"), "");
			});
			
			//업무 변경
		 	$(".msEdit").on('click', function(){
		 		collabUtil.openTaskAddPopup("CollabTaskSavePopup", "callbackTaskSave", $(this).data("taskseq"), "${prjData.prjType }", "${prjData.prjSeq }", $(this).data("sectionseq"), "${prjData.PrjName }", $(this).data("sectionname"))//업무 상세화면
			});
			
			//업무 삭제
			$(".msDel").on('click', function(){
				var obj = $(this);
				Common.Confirm(Common.getDic("msg_RUDelete"), "Confirmation Dialog", function(result){	// 삭제 하시겠습니까?
		       		if(result){
		       			$.ajax({
	                		type:"POST",
	                		data:{
	                			  "taskSeq"		: obj.data("taskseq")
	                			, "parentKey"	: ""
	                			, "objectID"	: ""
	                			, "objectType"	: ""
	                		},
	                		url:"/groupware/collabTask/deleteTask.do",
	                		success:function (data) {
	                			if(data.status == "SUCCESS"){
	                				obj.closest("li").remove(); 

	                				if ($("#mileList").find("li").length == 0) {
	                					$("#divEmptyMileStone").show();
	                				}
	                			}
	                			else{
	                				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
	                			}
	                		},
	                		error:function (request,status,error){
	                			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	                		}
	                	});
		       		}
				});				
	        });
			
			//섹션변경
			$(".btnSecChg").on('click', function(){
				var popupID = "CollabSectionPopup";
				var openerID = "CollabMain";
				var popupTit = "[${prjData.PrjName }] " + Common.getDic("btn_ModiSection");
				
				if($(this).data("name") == "hold"){	//섹션명 변경(임시섹션 변경)
					var popupYN = "N";
					var callBack = encodeURI(JSON.stringify({'prjSeq': '${prjData.PrjSeq }', 'prjType': '${prjData.prjType }', 'taskSeq': $(this).data("taskseq"), 'isMile': 'Y'}));
					var popupUrl = "/groupware/collabProject/CollabSectionPopup.do?"
						+ "&prjType=" + "${prjData.PrjType }"
						+ "&prjSeq=" + "${prjData.PrjSeq }"
						+ "&taskSeq=" + $(this).data("taskseq")
						+ "&prjName=" + "${prjData.PrjName }"
						+ "&sectionSeq=" + $(this).data("seq")
						+ "&sectionName=" + $(this).data("name")
						+ "&isMile=Y"
						+ "&popupID=" + popupID
						+ "&openerID=" + openerID
						+ "&popupYN=" + popupYN
						+ "&callBackParam=" + callBack;
					Common.open("", popupID, popupTit, popupUrl, "310px", "160px", "iframe", true, null, null, true);
				}else{
					var popupUrl = "/groupware/collabProject/CollabSectionChangePopup.do?"
						+ "&prjType=" + "${prjData.PrjType }"
						+ "&prjSeq=" + "${prjData.PrjSeq }"
						+ "&taskSeq=" + $(this).data("taskseq");
						
					Common.open("", popupID, popupTit, popupUrl, "310px", "400px", "iframe", true, null, null, true);
				}
			});
			
			//완료 처리
			$(".milestone input[type=checkbox]").on('click', function(e){
				var oCheckBox = $(this);
				var nTaskSeq = $(oCheckBox).data("taskseq");
				var nTaskStatus = $(oCheckBox).is(':checked');
				var sMessage = "";
				if (nTaskStatus) {
					sMessage = Common.getDic("msg_TaskClose"); // 마감 하시겠습니까?
				}
				else {
					sMessage = Common.getDic("msg_att_cancel"); // 취소 하시겠습니까?
				}

				e.preventDefault(); // 이벤트 취소
				
				parent.Common.Confirm(sMessage, "", function (result) {
					if (result) {
						var	data={"taskSeq": nTaskSeq, "taskStatus": nTaskStatus};
						collabUtil.saveTaskComplete(data, function (res) {
							if (nTaskStatus) {
								$(oCheckBox).prop('checked', true);
							}
							else {
								$(oCheckBox).prop('checked', false);
							}
						});
					}
				});
			});
		},
		getProjectData:function(){
			var trgMileArr = new Array();
		 	$('#tblMileForm tbody tr').each(function (i, v) {
				var item = $(v).find('.msDetail').data();
				trgMileArr.push({ "taskSeq":(item != undefined && item.taskseq != undefined ? item.taskseq : "") });
			});
			
			var trgUserFormArr = new Array();
		 	$('#tblUserForm tbody tr').each(function (i, v) {
				var item = $(v);
				var saveData = { "optionTitle":item.find('.txtTitle').val(), "optionVal":item.find('.txtVal').val(), "optionType":item.find('.txtType').val()};
				trgUserFormArr.push(saveData);
			});
		 	
		 	var delFileArr = new Array();
		 	for (var i=0; i < collabProjectAdd.fileList.length; i++){
		 		var bFind=false;
			 	for (var j=0; j < coviFile.fileInfos.length; j++){
		 			if (collabProjectAdd.fileList[i].FileID == coviFile.fileInfos[j].FileID){
		 				bFind=true;
		 				break;
		 			}
			 	}
		 		if (bFind== false){
		 			delFileArr.push(collabProjectAdd.fileList[i]);
		 		}
		 	}
			
		 	
// v.replace(/\"/g,"'")
			var formData = new FormData($('#form1')[0]);
			formData.append("prjName", $("#prjName").val().replace(/\'/gi, "′").replace(/\"/gi, "″"));
			formData.append("startDate", $("#startDate").val());
			formData.append("endDate",$("#endDate").val());
			formData.append("remark", $("#remark").val());
			formData.append("prjStatus", $('.check_class:checked').val());
			formData.append("progRate", $("#progRate").val());
			formData.append("trgManager", JSON.stringify(collabUtil.getUserArray("resultViewManager")));
			formData.append("trgMember", JSON.stringify(collabUtil.getUserArray("resultViewMember")));
			formData.append("trgViewer", JSON.stringify(collabUtil.getUserArray("resultViewViewer")));
			formData.append("trgMileForm", JSON.stringify(trgMileArr));
			formData.append("trgUserForm", JSON.stringify(trgUserFormArr));
			formData.append("delFile", JSON.stringify(delFileArr));
			
			var selectedColor = coviCtrl.getSelectColor();
			formData.append("prjColor", selectedColor.split(":")[1]);
			
		    for (var i = 0; i < coviFile.files.length; i++) {
		    	if (typeof coviFile.files[i] == 'object') {
		    		formData.append("file", coviFile.files[i]);
		        }
		    }
			
			return formData;
		},
		openOrgMapLayerPopup:function(callBackFunc, trgId){
			//Common.open("","orgmap_pop","조직도","/covicore/control/goOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=D9","1060","580","iframe",true,null,null,true);
        	var trgArr = new Array();
		 	$('#'+trgId).find('.user_img').each(function (i, v) {
				var item = $(v);
				var userData = { "itemType":"user", "code":item.data('code'), "UserCode":item.data('code'), "UserID":item.data('UserID'), "DN":item.data('DisplayName'), "RGNM":item.data('DeptName'),"Dis":true, "ETNM":item.data('ETNM'),"TL":item.data('TL'),"PO":item.data('PO'),"LV":item.data('LV')};
				trgArr.push(userData);
			});
		 	initData["item"] = trgArr		 	
			url = "/covicore/control/goOrgChart.do?callBackFunc="+callBackFunc+"&type=B9&treeKind=Group&groupDivision=Basic&drawOpt=_MARB&setParamData=initData";			
			title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
			var w = "1000";
			var h = "580";
			CFN_OpenWindow(url,"openGroupLayerPop",w,h,"");
		},
		orgMapLayerPopupCallBack:function(orgData, reqOrgMapTarDiv) {
			var data = $.parseJSON(orgData);
			var item = data.item
			var len = item.length;
			
			if (item != '') {
				var duplication = false; // 중복 여부
				var maxCount = false;
				$.each(item, function (i, v) {
					//var cloned = collabProjectAdd.orgMapDivEl.clone();
					if (!v.Dis  ) {
						var type = (v.itemType == 'user') ? 'UR' : 'GR';
						var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;
						var ETNM = (v.itemType == 'user') ? v.ETNM : "";
						var TL = (v.itemType == 'user') ? v.TL : "";
						var PO = (v.itemType == 'user') ? v.PO : "";
						var LV = (v.itemType == 'user') ? v.LV : "";
						var DeptName = v.ExGroupName!= null ? v.ExGroupName.split(';')[0] :"";
						var PhotoPath = v.PhotoPath;
						if ($('#' + reqOrgMapTarDiv).find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 0) {
							duplication = true;
							return true;;
						}
						
						if ($('#' + reqOrgMapTarDiv).find(".user_img").length >=49){
							maxCount = true;
							return true;
						}
	    				var cloned = collabUtil.drawProfile({"code":code,"type":type,"PhotoPath":PhotoPath,"DisplayName":CFN_GetDicInfo(v.DN),"DeptName":DeptName,"ETNM":ETNM,"TL":TL,"PO":PO,"LV":LV}, true);
	    				$('#' + reqOrgMapTarDiv + ' .ui-autocomplete-input').before(cloned);
					}	
				});
				
				if(duplication){
					Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
				}
					
				if (maxCount){
					Common.Warning('<spring:message code="Cache.msg_collab2" />');	//최대 가능수[50인]를 초과하였습니다. 더이상 추가되지 않습니다.
				}
			}
			
			if(reqOrgMapTarDiv == "resultViewMember"){	//담당자 데이터 변수저장 
				memberList = new Array();
				$.each($('#resultViewMember').find(".user_img"), function (i, v){
					var type = 'UR';
					var code = $(v).attr("code");
					var img = ($(v).find("img").attr("src") != undefined) ? $(v).find("img").attr("src") : "";
					var titleArr = $(v).attr("title").split(' | ');

					var dataObj = new Object();
					dataObj = {"type":"UR","code":code,"type":type,"PhotoPath":img,"DisplayName":titleArr[1],"DeptName":titleArr[0],"UserID":code};
					memberList.push(dataObj);
				});
			}
			
		},
		validationChk:function(){
			var returnVal= true;
	
			if ($('.check_class:checked').length == 0){
				Common.Warning("<spring:message code='Cache.msg_task_selectState'/>");
			    return false;
			}
				
			if(!(0 <= $("#progRate").val() && $("#progRate").val() <= 100)){
				Common.Warning("<spring:message code='Cache.msg_checkPercent'/>", "Warning Dialog") //진행율을 0~100이하로 입력해주세요.
				return false;
			}
			
			if ($(".milestoneAdd").length>0){
				Common.Error("<spring:message code='Cache.msg_JobNotRegistered' />");	//등록 안 된 업무가 있습니다.
				return;
			}
			//자동완성 안 된 관리자 체크
			if($.trim($("#resultViewManagerInput").val()).length > 0 ){
				Common.Error("<spring:message code='Cache.lbl_apv_noenter' />(<spring:message code='Cache.lbl_apv_Admin' />)"); // 입력 되지 않았습니다. (관리자)
				return;
			}
			//자동완성 안 된 담당자 체크
			if($.trim($("#resultViewMemberInput").val()).length > 0 ){
				Common.Error("<spring:message code='Cache.lbl_apv_noenter' />(<spring:message code='Cache.lbl_Res_Admin' />)"); // 입력 되지 않았습니다. (담당자)
				return;
			}
			//자동완성 안 된 조회자 체크
			if($.trim($("#resultViewViewerInput").val()).length > 0 ){
				Common.Error("<spring:message code='Cache.lbl_apv_noenter' />(<spring:message code='Cache.btn_Viewer' />)"); // 입력 되지 않았습니다. (조회자)
				return;
			}
				
			return returnVal;
	 },
	 changeSection: function(retData){
		$(".btnSecChg").each(function () {
			if($(this).data("taskseq") == retData.taskSeq){
				$(this).data({"name":retData.SectionName, "seq":retData.SectionSeq, "taskseq":$(this).data("taskseq")});
				$(this).text(retData.SectionName);
			}
		});
	 }
}

$(document).ready(function(){
	collabProjectAdd.objectInit();
});

function orgMemberCallback(orgData){
	collabProjectAdd.orgMapLayerPopupCallBack(orgData, "resultViewMember");
}
function orgManagerCallback(orgData){
	collabProjectAdd.orgMapLayerPopupCallBack(orgData, "resultViewManager");
}
function orgViewerCallback(orgData){
	collabProjectAdd.orgMapLayerPopupCallBack(orgData, "resultViewViewer");
}

window.addEventListener( 'message', function(e){
    // 부모창의 함수 실행
    switch (e.data.functionName){
		case "callbackOrgMember"://담당자
			var list = e.data.params.list;
			var duplication = false; // 중복 여부
			var personCnt = list.length;
			
			$.each(list, function (i, v){
				var type = 'UR';
				var code = v.UserCode;
				
				if ($('#subViewMember').find(".user_img[type='"+ type+"'][code='"+ code+"']").length > 0) {
					duplication = true;
					return true;
				}
				
				var cloned = collabUtil.drawProfileOne({"code":code,"type":type,"DisplayName":CFN_GetDicInfo(v.DisplayName),"DeptName":v.DeptName, "personCnt":personCnt}, true);
				$('#subViewMember').append(cloned);
			});
			
			if ($('#subViewMember').find(".user_img").length > 0){
				personCnt = $('#subViewMember').find(".user_img").length;
				$('#subViewMember').find(".btn_member").text(personCnt);
			}
			
			if(duplication){
				Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
			}
		break;
		case "callbackTaskSave":	//업무 변경
			var data = e.data.params;
			var personCnt = data.memberList.length;
			
			$("#taskname_"+data.taskSeq).val(data.taskName);
			
			$.each(data.memberList, function (i, v){
				var type = 'UR';
				var code = v.UserCode;
				
				var cloned = collabUtil.drawProfileOne({"code":code,"type":type,"DisplayName":CFN_GetDicInfo(v.DisplayName),"DeptName":v.DeptName, "personCnt":personCnt}, true);
				$("#sub_"+data.taskSeq).html(cloned);
			});
			
		break;
	}
});

var initData ={};

</script>