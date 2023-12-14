<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:650px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents" id="docManageAddArea">
		<div class="popContent" style="position:relative;">
			<div class="middle">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 200px;">
						<col style="width: 400px;">
					</colgroup>
					<tbody>
						<tr>
							<th><spring:message code='Cache.lbl_apv_ChargeDept' /></th> <!-- 담당부서 -->
							<td>
								<div class="box">
									<span>
										<input id="selDept" type="input" readonly="readonly" value="${list[0].DeptName}">
										<a id="selectAuthDept" class="btnTypeDefault"><spring:message code='Cache.lbl_Select' /></a> <!-- 선택 -->
									</span>							
								</div>								
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_apv_charge_person' /></th> <!-- 담당자 -->
							<td>
								<div class="box">
									<span>										
										<a id="selectAuthUser" class="btnTypeDefault"><spring:message code='Cache.lbl_Select' /></a> <!-- 선택 -->
										<a id="deleteAuthUser" class="btnTypeDefault"><spring:message code='Cache.lbl_apv_delete' /></a> <!-- 삭제 -->
									</span>
									<div style="border: #c4c4c4 1px solid; overflow-y: auto; margin: 2px; height:190px">
								        <table cellspacing="0" cellpadding="0" width="100%" border="0" >
									        <tbody id="selAuthUserVW"></tbody>
								        </table>
						        	</div>							
								</div>								
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_apv_save' /></a> <!-- 저장 -->
				<a id="btnDelete" class="btnTypeDefault" style="display: none;"><spring:message code='Cache.lbl_apv_delete' /></a> <!-- 삭제 -->
				<a id="btnClose" class="btnTypeDefault"><spring:message code='Cache.btn_apv_cancel' /></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>

<script>
	var obj = function(id){
		var obj = {};		
		
		if(id.length > 0){
			var chkArr = $("#selAuthUserVW input[type=checkbox]");
			
			obj.user = $.makeArray(chkArr).reduce(function(acc, cur, idx, arr){
				var obj = cur.dataset;					
				return acc = acc.concat({userId: obj.code});	
			}, []);
			obj.dept = {code: id};
		} 
		
		return{
			setUser: function(param){obj.user = param},
			setDept: function(param){obj.dept = param},
			get: function(){return obj}
		}
	}
	
	$(document).ready(function(){
		var input = new obj("${deptCode}");
		
		$("#selectAuthUser").on("click", function(){
			parent.Common.open("", "orgcharPopup", "<spring:message code='Cache.lbl_DeptOrgMap'/>"
					,"/covicore/control/goOrgChart.do?type=B9&treeKind=Dept&allCompany=Y&callBackFunc=callBackOrgChartPopup&setParamData=initData", "1060px", "585px", "iframe", true, null, null, true);			
			parent.callBackOrgChartPopup = function(result){
				var result		= JSON.parse(result).item;
				var $fragment	= $(document.createDocumentFragment());				
				var chkArr		= $.makeArray($("#selAuthUserVW input[type=checkbox]").map(function(idx, item){return $(item).data("code")}));
				
				var selectArr = result.reduce(function(acc, cur, idx, arr){
					if(chkArr.indexOf(cur.AN) > -1) return acc;
					var cfnNm	= CFN_GetDicInfo(cur.DN);
					var $tr		= $("<tr>");
					var $td		= $("<td>");
					var $input	= $("<input>", {"type": "checkbox", "name": "chk", "style": "width: 20px; text-align:right;", "align": "left"}).data("code", cur.AN);
					
					$tr.append(
						$td.append($input).append(" " + cfnNm)
					).appendTo($fragment);
					
					return acc = acc.concat({userId: cur.AN}); 
				}, input.get().user ? input.get().user : []);
				
				$("#selAuthUserVW").append($fragment);
				input.setUser(selectArr);				
			}
		});
		
		$("#selectAuthDept").on("click", function(){
			parent.Common.open("", "orgcharPopup", "<spring:message code='Cache.lbl_DeptOrgMap'/>"
					,"/covicore/control/goOrgChart.do?type=C1&treeKind=Dept&allCompany=Y&callBackFunc=callBackOrgChartPopup&setParamData=initData", "1060px", "585px", "iframe", true, null, null, true);			
			parent.callBackOrgChartPopup = function(result){
				var result	= JSON.parse(result).item[0];
				var cfnNm	=	CFN_GetDicInfo(result.DN); 
				
				$("#selDept").val(cfnNm);
				input.setDept({code: result.AN});	
			}
		});
		
		$("#deleteAuthUser").on("click", function(){
			var data	= input.get().user;
			var chkArr	= $("#selAuthUserVW input[type=checkbox]:checked");
			var rmcodes	= [];
			
			chkArr.map(function(idx, item){
				rmcodes = rmcodes.concat([$(item).data("code")]);				
				return $(item).parent().parent().get(0); 
			}).remove();			
			input.setUser(data.filter(function(item, idx){return rmcodes.indexOf(item.userId) === -1}));
		});

		$("#btnClose").on("click", function(){parent.Common.close("addUser");});
		
		$("#btnSave").on("click", function(){
			var data = input.get();
			
			if(data.dept == null || data.dept == ""){
				Common.Inform("<spring:message code='Cache.msg_apv_021'/>"); // 담당부서를 선택하셔야 합니다.
				return false;
			}
			
			if(data.user == null || data.user == ""){
				Common.Inform("<spring:message code='Cache.msg_apv_181'/>"); // 담당자를 지정하십시요.
				return false;
			}
			
			$.ajax({
				url: "/approval/user/insertGovDocInOutUser.do",
				type: "POST",
				data: {
					data: JSON.stringify(data)
				},			
				success: function(data){			
					Common.Inform(data.message, "Information", function(result){
						if(result){
							parent.Common.close("addUser");
							parent.ListGrid.reloadList();
						}	
					});
				},
				error: function(response, status, error){
					Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
				}
			});
		});
		
		$("#btnDelete").on("click", function(){
			Common.Confirm("<spring:message code='Cache.msg_RUDelete' />", "<spring:message code='Cache.lbl_apv_delete' />", function(result){
				if(result){
					var data = input.get();
					$.ajax({
						url: "/approval/user/deleteGovDocInOutUser.do",
						type: "POST",
						data: {
							code: data.dept.code
						},
						success: function(data){
							Common.Inform(data.message, "Information", function(result){
								if(result){
									parent.Common.close("addUser");
									parent.ListGrid.reloadList();
								}	
							});
						},
						error: function(response, status, error){
							Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
						}
					});
				}
			});
		});
		
		if(CFN_GetQueryString("mode") == "M"){
			$("#btnDelete").show();
			$("#selectAuthDept").hide();
			
			$.ajax({
				url: "/approval/user/getGovDocInOutManager.do",
				type: "POST",
				data: {
					deptCode: CFN_GetQueryString("deptCode") == "undefined" ? "" : CFN_GetQueryString("deptCode")
				},
				success: function(data){
					if(data.list != null && data.list != ""){
						var list			= data.list[0];
						var authorityIDArr	= list.ListAuthorityID.split(";");
						var $fragment		= $(document.createDocumentFragment());				
						var chkArr			= $.makeArray($("#selAuthUserVW input[type=checkbox]").map(function(idx, item){return $(item).data("code")}));
						
						var selectArr = list.ListAuthorityName.split(", ").reduce(function(acc, cur, idx, arr){
							var $tr		= $("<tr>");
							var $td		= $("<td>");
							var $input	= $("<input>",{"type": "checkbox", "name": "chk", "style": "width: 20px; text-align:right;", "align": "left"}).data("code", authorityIDArr[idx]);
							
							$tr.append(
								$td.append($input).append(" " + cur)
							).appendTo($fragment);
							
							return acc = acc.concat({userId: authorityIDArr[idx]}); 
						}, input.get().user ? input.get().user : []);
						
						$("#selAuthUserVW").append($fragment);
						input.setUser(selectArr);
					}
				},
				error: function(response, status, error){
					Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
				}
			});
		}else{
			var deptName = CFN_GetQueryString("deptName") == "undefined" ? "" : CFN_GetQueryString("deptName");
			$("#selDept").val(decodeURIComponent(deptName));
		}
	});
</script>