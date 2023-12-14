<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<script type="text/javascript" src="/groupware/resources/script/user/bizcard.js"></script>
	<script type="text/javascript" src="/groupware/resources/script/user/bizcard_list.js"></script>
	
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	
	<style>
		p {
			margin-bottom: 5px;
		}
		
		th {
			background-color: rgba(245, 245, 245, 0.5);
		}
	
		.tdfile {
			padding-right: 5px;
			font-size: 11pt;
			background: url("/HtmlSite/smarts4j_n/covicore/resources/images/covision/table_th_line.gif") no-repeat right;
		}
		
		#tblFile {
			width: 100%;
			border: 1px solid lightgray;
		}
		
		#tblFile td, #tblFile th {
			border: 1px solid lightgray;
		}
		
		.innerTable td {
			border: 0px !important;
		}
		
		.innerTable {
			margin: 5px 0px 5px 15px;
			width: 100%;
		}
		
		#spnEachCount {
			color: rgba(84, 167, 234, 0.8);
		}
	</style>
</head>

<div>
	<div class="cRConTop titType">
		<h2 class="title"><spring:message code='Cache.lbl_ExportContact' /></h2>
	</div>
	<div class="cRContBottom mScrollVH">
		<div class="bizcardAllCont">
			<div class="bizCardOutput">

				<!-- 연락처 내보내기 table -->
				<table class="tableTypeRow">
					<caption><spring:message code='Cache.lbl_ExportContact' /></caption>
					<colgroup>
						<col style="width: 15.2%;">
						<col style="width: auto;">
					</colgroup>
					<tbody>
						<tr>
							<th><spring:message code='Cache.lbl_FileType' /></th>
							<td>
								<div class="box02">
									<ul>
										<li>
											<div class="radioStyle05">
												<input type="radio" id="r1" name="rdoFileType" value="CSV_EX" />
												<label for="r1" class="colorBk">CSV(Express)</label>
												<span class="txt"><spring:message code='Cache.lbl_bizcard_explainCSVExpress' /></span>
											</div>
										</li>
										<li>
											<div class="radioStyle05">
												<input type="radio" id="r2" name="rdoFileType" value="CSV" />
												<label for="r2" class="colorBk">CSV</label>
												<span class="txt"><spring:message code='Cache.lbl_bizcard_explainCSV' /></span>
											</div>
										</li>
										<li>
											<div class="radioStyle05">
												<input type="radio" id="r3" name="rdoFileType" value="EXCEL" />
												<label for="r3" class="colorBk">XLS</label>
												<span class="txt"><spring:message code='Cache.lbl_bizcard_explainExcel' /></span>
											</div>
										</li>
										<li>
											<div class="radioStyle05">
												<input type="radio" id="r4" name="rdoFileType" value="VCF" />
												<label for="r4" class="colorBk">VCF</label>
												<span class="txt">VCF</span>
											</div>
										</li>
									</ul>
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_SelectItem' /></th>
							<td>
								<div class="box02">
									<div class="chkStyle06 checkAll">
										<input type="checkbox" id="ckAll" name="chkItem" value="ALL" onchange="checkAllSelect(this);"/>
										<label for="ckAll"><spring:message code='Cache.lbl_selectall' /></label>
									</div>
									<ul class="checkboxWrap">
										<li class="chkStyle06">
											<input type="checkbox" id="ck1" name="chkItem" value="Name" checked="checked" disabled="disabled" />
											<label for="ck1"><spring:message code='Cache.lbl_name' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck2" name="chkItem" value="CellPhone" />
											<label for="ck2"><spring:message code='Cache.lbl_MobilePhone' /></label>
										</li>										
										<li class="chkStyle06">
											<input type="checkbox" id="ck4" name="chkItem" value="EMAIL" />
											<label for="ck4"><spring:message code='Cache.lbl_Email2' /> </label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck5" name="chkItem" value="MessengerID" />
											<label for="ck5"><spring:message code='Cache.lbl_Messanger' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck6" name="chkItem" value="ComName" />
											<label for="ck6"><spring:message code='Cache.lbl_Company' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck7" name="chkItem" value="ComPhone" />
											<label for="ck7"><spring:message code='Cache.lbl_Office_Line' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck8" name="chkItem" value="FAX" />
											<label for="ck8"><spring:message code='Cache.lbl_Office_Fax' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck9" name="chkItem" value="DeptName" />
											<label for="ck9"><spring:message code='Cache.lbl_dept' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck10" name="chkItem" value="JobTitle" />
											<label for="ck10"><spring:message code='Cache.lbl_JobTitle' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck11" name="chkItem" value="Memo" />
											<label for="ck11"><spring:message code='Cache.lbl_Memo' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck12" name="chkItem" value="EtcPhone" />
											<label for="ck12"><spring:message code='Cache.lbl_EtcPhone' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck3" name="chkItem" value="HomePhone" />
											<label for="ck3"><spring:message code='Cache.lbl_HomePhone' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck13" name="chkItem" value="DirectPhone" />
											<label for="ck13"><spring:message code='Cache.lbl_DirectPhone' /></label>
										</li>
										<!--  
										<li class="chkStyle06">
											<input type="checkbox" id="ck2" name="chkItem" value="AnniversaryText" />
											<label for="ck2"><spring:message code='Cache.lbl_AnniversarySchedule' /></label>
										</li>
										-->
										<%-- <li class="chkStyle06">
											<input type="checkbox" id="ck13" name="chkItem" value="ComZipcode" />
											<label for="ck13"><spring:message code='Cache.lbl_ComZipCode' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck14" name="chkItem" value="ComAddress" />
											<label for="ck14"><spring:message code='Cache.lbl_ComAddress' /></label>
										</li>
										<li class="chkStyle06">
											<input type="checkbox" id="ck15" name="chkItem" value="ComWebSite" />
											<label for="ck15"><spring:message code='Cache.lbl_homepage' /></label>
										</li> --%>
									</ul>
								</div>
							</td>
						</tr>
						<tr>
							<th>
								<div class="selBox">
									<label for="selTarget"><spring:message code='Cache.lbl_SelectTarget' /></label>
									<select id="selTarget" class="selectType02" onchange="changeTargetType(this);">
										<option value="ShareType"><spring:message code='Cache.lbl_Division' /></option>
										<option value="ALL"><spring:message code='Cache.lbl_all' /></option>
										<option value="Each"><spring:message code='Cache.lbl_each' /></option>
									</select>
								</div>
							</th>
							<td>
								<!-- 구분으로 선택 되었을 때 -->
							 	<div class="selCont" id="divTargetShareType">
								<dl class="dlBox">
									<dt>
										<span class="alarm type01">
											<span><spring:message code='Cache.lbl_ShareType_Personal' /></span>
											<a href="#" class="onOffBtn" name="onOffShareType" onclick="clickShareType(this);">
												<span></span><input type="text" value="P" style="display: none;">
											</a>
										</span>
									</dt>
									<dd class="box02" id="ddTarget_p" style="display:none;">
										<div class="chkStyle06 checkAll">
											<input type="checkbox" id="ckAll2" name="chkTarget_p" value="ALL" onchange="checkAllSelect(this);"/>
											<label for="ckAll2"><spring:message code='Cache.lbl_selectall' /></label>
										</div>
									</dd>
								</dl>
								<dl class="dlBox">
									<dt>
										<span class="alarm type01">
											<span><spring:message code='Cache.lbl_ShareType_Dept' /></span>
											<a href="#" class="onOffBtn" name="onOffShareType" onclick="clickShareType(this);">
												<span></span><input type="text" value="D" style="display: none;">
											</a>
										</span>
									</dt>
									<dd class="box02" id="ddTarget_d" style="display:none;">
										<div class="chkStyle06 checkAll">
											<input type="checkbox" id="ckAll3" name="chkTarget_d" value="ALL" onchange="checkAllSelect(this);"/>
											<label for="ckAll3"><spring:message code='Cache.lbl_selectall' /></label>
										</div>
									</dd>
								</dl>
								<dl class="dlBox">
									<dt>
										<span class="alarm type01">
											<span><spring:message code='Cache.lbl_ShareType_Comp' /></span>
											<a href="#" class="onOffBtn" name="onOffShareType" onclick="clickShareType(this);">
												<span></span><input type="text" value="U" style="display: none;">
											</a>
										</span>
									</dt>
									<dd class="box02" id="ddTarget_u" style="display:none;">
										<div class="chkStyle06 checkAll">
											<input type="checkbox" id="ckAll4" name="chkTarget_u" value="ALL" onchange="checkAllSelect(this);"/>
											<label for="ckAll4"><spring:message code='Cache.lbl_selectall' /></label>
										</div>
									</dd>
								</dl>
								</div>
								<!-- // 구분으로 선택 되었을 때 -->
								<!-- 전체로 선택 되었을 때 -->
								<div class="selCont saveFileBox" id="divTargetAll" style="display: none;">
									<p class="txt"><spring:message code='Cache.msg_bizcard_saveEntireContactToFile' /></p>
								</div>
								<!-- // 전체로 선택 되었을 때 -->
								<!-- 개별로 선택 되었을 때 -->
								<div class="selCont saveFileBox" id="divTargetEach" style="display: none;">
									<p class="txt"><spring:message code='Cache.msg_bizcard_saveEachContactToFile' /></p>
								</div>
								<!-- // 개별로 선택 되었을 때 -->
							</td>
						</tr>
					</tbody>
				</table>
				<!-- // 연락처 내보내기 table -->

				<div class="btnBttmWrap">
					<a href="#" id="btnSave" class="btnTypeDefault btnThemeBg lg" onclick="exportBizCard();"><spring:message code='Cache.btn_SaveAsFile' /></a>
				</div>
			</div>
		</div>												
	</div>					
</div>

<script>
	$(function() {
		var trResult = "";
		var i = 0;
		
		$.ajaxSetup({
		     async: false
		});
		
		//개인 그룹 바인딩
		trResult = "<ul class='checkboxWrap'>";
		
		trResult += "<li class='chkStyle06'>";
		trResult += "	<input type='checkbox' name='chkTarget_p' value='P_noGroup' id='ck" + 0 + "_p'><label for='ck" + 0 + "_p'>그룹 없음</label>";
		trResult += "</li>";
		
		i = 1;
		$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : 'P'}, function(d) {
			d.list.forEach(function(d) {
				trResult += "<li class='chkStyle06'>";
				trResult += "	<input type='checkbox' name='chkTarget_p' value='" + d.GroupID + "' id='ck" + i + "_p'><label for='ck" + i + "_p'>" + d.GroupName + "</label>";
				trResult += "</li>";
				i++;
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
		
		trResult += "</ul>";
		
		$("#ddTarget_p").find("div").after(trResult);
		
		//부서 그룹 바인딩
		trResult = "<ul class='checkboxWrap'>";
		trResult += "<li class='chkStyle06'>";
		trResult += "	<input type='checkbox' name='chkTarget_d' value='D_noGroup' id='ck" + 0 + "_d'><label for='ck" + 0 + "_d'>그룹 없음</label>";
		trResult += "</li>";
		
		i = 1;
		$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : 'D'}, function(d) {
			d.list.forEach(function(d) {
				trResult += "<li class='chkStyle06'>";
				trResult += "	<input type='checkbox' name='chkTarget_d' value='" + d.GroupID + "' id='ck" + i + "_d'><label for='ck" + i + "_d'>" + d.GroupName + "</label>";
				trResult += "</li>";
				i++;
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
		
		trResult += "</ul>";
		
		$("#ddTarget_d").find("div").after(trResult);
		
		//회사 그룹 바인딩
		trResult = "<ul class='checkboxWrap'>";
		trResult += "<li class='chkStyle06'>";
		trResult += "	<input type='checkbox' name='chkTarget_u' value='U_noGroup' id='ck" + 0 + "_u'><label for='ck" + 0 + "_u'>그룹 없음</label>";
		trResult += "</li>";
		
		i = 1;
		$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : 'U'}, function(d) {
			d.list.forEach(function(d) {
				trResult += "<li class='chkStyle06'>";
				trResult += "	<input type='checkbox' name='chkTarget_u' value='" + d.GroupID + "' id='ck" + i + "_u'><label for='ck" + i + "_u'>" + d.GroupName + "</label>";
				trResult += "</li>";
				i++;
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
		
		trResult += "</ul>";
		
		$("#ddTarget_u").find("div").after(trResult);
		
		//개별 내보내기할 연락처 개수
		var selected_bizcard = "${BizCardID}";
		var selected_bizcard_group = "${BizGroupID}";
		
		var count = 0;
		if(selected_bizcard != "" || selected_bizcard_group != "") {
			if(selected_bizcard != "") {
				count += selected_bizcard.split(';').length;
			}
			
			if(selected_bizcard_group != "") {
				count += selected_bizcard_group.split(';').length;
			}
			
			$("#selTarget").val("Each");
			$("#divTargetShareType").css("display", "none");
			$("#divTargetAll").css("display", "none");
			$("#divTargetEach").css("display", "");
		}
		
		//$("#spnEachCount").text("(" + count + "개)");
		
		if(count == 0) {
			$("#selTarget").find("option").eq(2).remove();
		}
	});
	
	var exportBizCard = function() {
		
		if($("input[name=rdoFileType]:checked").length == 0) {
			Common.Warning("<spring:message code='Cache.msg_SelectFileType'/>"); //파일 형식을 선택해주세요.
			return;
		} else if($("#selTarget").val == "") {
			Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>"); //대상을 선택해주세요.
			return;
		}
		
		var itemList = "";
		var sField = "";
		$("input[name=chkItem]:checked").each(function (index) {
			if($("input[name=chkItem]:checked").eq(index).val() != "ALL") {
				itemList += $("input[name=chkItem]:checked").eq(index).next().text().trim()+ ";";
				sField += $("input[name=chkItem]:checked").eq(index).val() + ",";
			}
		});	
		
		var shareType = "";
		$("a[name=onOffShareType]").each(function (index) {
			if($("a[name=onOffShareType]").eq(index).hasClass("on")) {
				var type = $("a[name=onOffShareType]").eq(index).find("input[type=text]").val();
				if($("input[name=chkTarget_" + type.toLowerCase() + "]:checked").length > 0) {
					shareType += "'" + type + "',";
				}
			}
		});		
		
		var type_p = "";
		$("input[name=chkTarget_p]:checked").each(function (index) {
			if($("input[name=chkTarget_p]:checked").eq(index).val() != "ALL") {
				type_p += "'" + $("input[name=chkTarget_p]:checked").eq(index).val() + "',";
			}
		});
		
		var type_d = "";
		$("input[name=chkTarget_d]:checked").each(function (index) {
			if($("input[name=chkTarget_d]:checked").eq(index).val() != "ALL") {
				type_d += "'" + $("input[name=chkTarget_d]:checked").eq(index).val() + "',";
			}
		});
		
		var type_u = "";
		$("input[name=chkTarget_u]:checked").each(function (index) {
			if($("input[name=chkTarget_u]:checked").eq(index).val() != "ALL") {
				type_u += "'" + $("input[name=chkTarget_u]:checked").eq(index).val() + "',";
			}
		});
		
		if($("#selTarget").val() == "ShareType" && shareType == "") {
			Common.Warning("<spring:message code='Cache.msg_bizcard_selectTypeAndGroup'/>"); //분류 및 그룹을 선택해주세요. 다국어 추가 필요
			return;
		}
		
		var selected_bizcard = "${BizCardID}";
		var selected_bizcard_group = "${BizGroupID}";
		
		var arr_bizcard = selected_bizcard.split(";");
		var arr_bizcard_group  = selected_bizcard_group.split(";");
		
		var bizCardID = "";
		var bizGroupID = "";
		if(arr_bizcard.length > 0 && arr_bizcard[0] != "") {
			for(var i = 0; i < arr_bizcard.length; i++) {
				bizCardID += "'" + arr_bizcard[i] + "',";
			}
		}
		
		if(arr_bizcard_group.length > 0 && arr_bizcard_group[0] != "") {
			for(var i = 0; i < arr_bizcard_group.length; i++) {
				bizGroupID += "'" + arr_bizcard_group[i] + "',";
			}
		}
		
		var url = "/groupware/bizcard/ExportBizCardToFile.do";
		
		Common.Confirm("<spring:message code='Cache.msg_FileDownMessage'/>", "Confirm Dialog", function(result) {
			if(result){
				var headerName = itemList;
				var groupID = "";
				var	sortColumn = "RegistDate";//bizCardGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
				var	sortDirection = "DESC"; //bizCardGrid.getSortParam("one").split("=")[1].split(" ")[1]; 				  	
				
				location.href = url + "?sortColumn="+sortColumn+"&sortDirection="+sortDirection
						+"&fileType="+$("input[name=rdoFileType]:checked").val()+"&headerName="+encodeURI(encodeURIComponent(itemList.slice(0, -1)))+"&sField="+sField.slice(0, -1)
						+"&targetType="+$("#selTarget").val()+"&shareType="+shareType.slice(0, -1)
						+"&type_p="+type_p.slice(0, -1)+"&type_d="+type_d.slice(0, -1)+"&type_u="+type_u.slice(0, -1)
						+"&bizCardID="+bizCardID.slice(0, -1)
						+"&bizGroupID="+bizGroupID.slice(0, -1);
			}
		});		
	}
	
	var changeTargetType = function(obj) {
		if($(obj).val() == "ShareType") {
			$("#divTargetShareType").css("display", "");
			$("#divTargetAll").css("display", "none");
			$("#divTargetEach").css("display", "none");
		} else if($(obj).val() == "ALL") {
			$("#divTargetShareType").css("display", "none");
			$("#divTargetAll").css("display", "");
			$("#divTargetEach").css("display", "none");
		} else if($(obj).val() == "Each") {
			$("#divTargetShareType").css("display", "none");
			$("#divTargetAll").css("display", "none");
			$("#divTargetEach").css("display", "");
		}
	}
	
	var clickShareType = function(obj) {
		if(!$(obj).hasClass("on")) {
			$(obj).addClass('on');	
			if($(obj).find("input[type=text]").val() == "P") {
				if($("#ddTarget_p").find("li").length > 0) {
					$("#ddTarget_p").css("display", "");	
				} else {
					$("input[name='chkTarget_p']").trigger("click");
				}
			} else if($(obj).find("input[type=text]").val() == "D") {
				if($("#ddTarget_d").find("li").length > 0) {
					$("#ddTarget_d").css("display", "");	
				} else {
					$("input[name='chkTarget_d']").trigger("click");
				}
			} else if($(obj).find("input[type=text]").val() == "U") {
				if($("#ddTarget_u").find("li").length > 0) {
					$("#ddTarget_u").css("display", "");	
				} else {
					$("input[name='chkTarget_u']").trigger("click");
				}
			}
		} else {
			$(obj).removeClass('on');
			if($(obj).find("input[type=text]").val() == "P") {
				$("#ddTarget_p").css("display", "none");
			} else if($(obj).find("input[type=text]").val() == "D") {
				$("#ddTarget_d").css("display", "none");
			} else if($(obj).find("input[type=text]").val() == "U") {
				$("#ddTarget_u").css("display", "none");
			}
		}
	}
	
	var checkAllSelect = function(obj) {
		if($(obj).attr("id") == "ckAll") {
			if(obj.checked) {
				// 항목에 표시된것만 체크			
				$("input[name=" + $(obj).attr("name") + "]").each(function () {
					if($(this).closest("li").is(":visible") || $(this).attr("id") == "ckAll") {
						$(this).prop("checked", true);	
					} else {
						$(this).prop("checked", false);
					}	
				});
			} else {
				$("input[name=" + $(obj).attr("name") + "]").prop("checked", false);
				
				if($(obj).attr("name") == "chkItem") {
					$("input[name=" + $(obj).attr("name") + "]").eq(1).prop("checked", true);
				}
			}
		}
	}
	
	$("input[type=radio][name=rdoFileType]").change(function(){
		if(this.value == "EXCEL") {
			$("input[type=checkbox][name=chkItem][value=EtcPhone]").closest("li").show();
	    	$("input[type=checkbox][name=chkItem][value=DirectPhone]").closest("li").show();
			$("input[type=checkbox][name=chkItem][value=MessengerID]").closest("li").show();
	    	$("input[type=checkbox][name=chkItem][value=Memo]").closest("li").show();
		} else if(this.value == "VCF") {
			$("input[type=checkbox][name=chkItem][value=EtcPhone]").prop("checked", false).closest("li").hide();
	    	$("input[type=checkbox][name=chkItem][value=DirectPhone]").prop("checked", false).closest("li").hide();
	    	$("input[type=checkbox][name=chkItem][value=MessengerID]").prop("checked", false).closest("li").hide();
	    	$("input[type=checkbox][name=chkItem][value=Memo]").prop("checked", false).closest("li").hide();
	    } else {
	    	$("input[type=checkbox][name=chkItem][value=EtcPhone]").prop("checked", false).closest("li").hide();
	    	$("input[type=checkbox][name=chkItem][value=DirectPhone]").prop("checked", false).closest("li").hide();
	    	$("input[type=checkbox][name=chkItem][value=MessengerID]").closest("li").show();
	    	$("input[type=checkbox][name=chkItem][value=Memo]").closest("li").show();
	    }
		
		if($("#ckAll").is(":checked")) {
			$("input[name='chkItem']").each(function () {
	 			if($(this).closest("li").is(":visible") || $(this).attr("id") == "ckAll") {
	 				$(this).prop("checked", true);	
	 			} else {
	 				$(this).prop("checked", false);
	 			}	
	 		});
		}
	});
</script>
