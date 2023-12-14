<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:416px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents" id="baseCodeViewSearchArea">	
		<div class="popContent" style="position:relative;">
			<div class="middle">
			관리자 체크시 "고객사"로 설정 됩니다.
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 200px;">
						<col style="width: 400px;">
					</colgroup>
					<tbody>
						<tr>
							<th>권한 사용자</th>
							<td>
								<div class="box">
									<span>
										<input id="selUser" type="input" readonly="readonly" value="${list[0].AUTHORITY_NAME}">
												
										<a id="selectAuthUser" class="btnTypeDefault">선택</a>
										<input id="adminYN" type="checkbox" ${list[0].ADMINYN eq 'Y' ? 'checked="checked"' : '' }>관리자
									</span>							
								</div>								
							</td>
						</tr>
						<tr>
							<th>담당 부서</th>
							<td>
								<div class="box">
									<span>										
										<a id="selectAuthDept" class="btnTypeDefault">선택</a>
										<a id="deleteAuthDept" class="btnTypeDefault">삭제</a>
									</span>
									<div style="border: #c4c4c4 1px solid;overflow-y: auto;margin: 2px; height:190px">
								        <table cellspacing="0" cellpadding="0" width="100%" border="0" >
									        <tbody id="selAuthDeptVW">
										        <c:forEach var="list" items="${list}">
										        	<tr>
										        		<td>
										        			<input type="checkbox" name="chk" style="width: 20px;text-align:right;" align="left" data-code="${list.MGRUNITCODE}"> ${list.DISPLAYNAME}	
										        		</td>	
										        	</tr>
										        </c:forEach>						        
									        </tbody>
								        </table>
						        	</div>							
								</div>								
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk">저장</a>
				<c:if test="${not empty authorityId}">
					<a id="btnDelete" class="btnTypeDefault">삭제</a>
				</c:if>
				<a id="btnClose" class="btnTypeDefault">취소</a>				
			</div>
		</div>
	</div>	
</div>

<script>

	var obj = function(id){		
		var obj={};		
		
		if( id.length > 0 ){
			var chkArr = $('#selAuthDeptVW input[type=checkbox]');
			
			obj.user = { userId : id };			
			obj.dept = $.makeArray(chkArr).reduce(function( acc,cur,idx,arr ){
					var obj = cur.dataset;					
					return acc = acc.concat({ code : obj.code });	
				},[]);
		} 
		
		return{
			setUser 	: function(param){ obj.user = param }
			,setDept 	: function(param){ obj.dept = param }
			,get 		: function(){ return obj }
		}
	}

	$(document).ready(function(){
		
		var input = new obj("${authorityId}");

		$("#selectAuthUser").on('click',function(){
			parent.Common.open("", "orgcharPopup", "<spring:message code='Cache.lbl_DeptOrgMap'/>"
					,"/covicore/control/goOrgChart.do?type=B1&treeKind=Dept&allCompany=Y&callBackFunc=callBackOrgChartPopup&setParamData=initData", '1060px', '585px', "iframe", true, null, null, true);			
			parent.callBackOrgChartPopup = function(result){
				var result 	= 	JSON.parse(result).item[0];
				var cfnNm 	=	CFN_GetDicInfo(result.DN); 
				$("#selUser").val( cfnNm );
				input.setUser({ userId : result.AN });	
			}
		});
		
		$("#selectAuthDept").on('click',function(){ 
			parent.Common.open("", "orgcharPopup", "<spring:message code='Cache.lbl_DeptOrgMap'/>"
					,"/covicore/control/goOrgChart.do?type=C9&treeKind=Dept&allCompany=Y&callBackFunc=callBackOrgChartPopup&setParamData=initData", '1060px', '585px', "iframe", true, null, null, true);			
			parent.callBackOrgChartPopup = function(result){
				var result 		= JSON.parse(result).item;
				var $fragment 	= $( document.createDocumentFragment() );				
				var chkArr 		= $.makeArray( $('#selAuthDeptVW input[type=checkbox]').map(function( idx,item ){ return $(item).data('code') }) );
				
				var selectArr = result.reduce(function( acc,cur,idx,arr ){					
					if( chkArr.indexOf( cur.AN ) > -1 ) return acc;
					var cfnNm = CFN_GetDicInfo(cur.DN);
					var $tr    = $("<tr>");
					var $td    = $("<td>");
					var $input = $("<input>",{ "type" : "checkbox", "name" : "chk", "style" : "width: 20px;text-align:right;", "align" : "left" }).data("code", cur.AN);
					
					$tr.append(
						$td.append( $input ).append(" "+cfnNm)
					).appendTo( $fragment );
					
					return acc = acc.concat({ code : cur.AN }); 
				}, input.get().dept ? input.get().dept : [] );
				
				$('#selAuthDeptVW').append( $fragment );
				input.setDept(selectArr);				
			}
		});
		
		$("#deleteAuthDept").on('click',function(){
			var data = input.get().dept;
			var chkArr = $('#selAuthDeptVW input[type=checkbox]:checked');
			var rmcodes=[];
			
			chkArr.map(function(idx,item){ 
				rmcodes = rmcodes.concat( [$(item).data('code')] );				
				return $(item).parent().parent().get(0); 
			}).remove();			
			input.setDept( data.filter(function( item,idx ){ return rmcodes.indexOf( item.code ) === -1 }) );
		});

		$("#btnClose").on('click',function(){ parent.Common.close("addUser"); });
		
		$("#btnSave").on('click',function(){
			var data = input.get();
			
			if(data.user == null || data.user == ""){
				Common.Inform("<spring:message code='Cache.msg_apv_181'/>"); // 담당자를 지정하십시요.
				return false;
			}
			if(data.dept == null || data.dept == ""){
				Common.Inform("<spring:message code='Cache.msg_apv_021'/>"); // 담당부서를 선택하셔야 합니다.
				return false;
			}
			
			$.ajax({
				url: '/approval/user/insertGovDocUser.do',
				type:"POST",
				data: { 
					data : JSON.stringify( input.get() )
					,adminYN : $('#adminYN').is(':checked') ? "Y" : "N"
				},			
				success:function (data) {			
					alert( data.message );
					parent.Common.close("addUser");
					parent.ListGrid.reloadList();
				},
				error:function(response, status, error){ 
					console.log( error ); 
				}
			});
		});
		
		$("#btnDelete").on('click',function(){			
			if( confirm('삭제 하시겠습니까?') ){				
				var data = input.get();			
				$.ajax({
					url: '/approval/user/deleteGovDocUser.do',
					type:"POST",
					data: { 
						userId : data.user.userId					
					},			
					success:function (data) {			
						alert( data.message );
						parent.Common.close("addUser");
						parent.ListGrid.reloadList();
					},
					error:function(response, status, error){ 
						console.log( error ); 
					}
				});				
			}			
		});
		
	});

	


</script>
