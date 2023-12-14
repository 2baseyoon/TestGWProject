<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">
	/* function chkPassword(){
		var password = $("#txtPwd").val();
		var data = {
				"ur_code" : Common.getSession("USERID"),
				"password" : password
		}
		$.ajax({
			url:"chkpassword.do",
			data:data,
			type:"post",
			success:function (res) {
				alert(res);
			},
			error:function (err) {
				alert(err);
			}			
		});
	} */
	
	function draft(){
		var data = {
				"formObj": JSON.stringify(JSON.parse($("#txt1").val()))
		};
		
		$.ajax({
			url:"draft.do",
			data:data,
			type:"post",
			success:function (res) {
				alert(res);
			},
			error:function (err) {
				alert(err);
			}			
		});
	}
	
	function abort(){
		var data = {
				"formObj": JSON.stringify(JSON.parse($("#txt1").val()))
		};
		
		$.ajax({
			url:"doAbort.do",
			data:data,
			type:"post",
			success:function (res) {
				alert(res);
			},
			error:function (err) {
				alert(err);
			}			
		});
	}
	
	/* function insertComment(d){
		if($("#formInstID").val()=="" || $("#UR_Code").val()=="" || $("#UR_Name").val()=="" || $("#mode").val()=="" || $("#kind").val()=="" || $("#comment").val()=="")
		{	alert("빈칸입력"); return false; }
		
		
		var data = {
				"formInstID":$("#formInstID").val(),
				"userID":$("#UR_Code").val(),
				"userName":$("#UR_Name").val(),
				"mode":$("#mode").val(),
				"kind":$("#kind").val(),
				"comment":$("#comment").val(),
		}
		
		$.ajax({
			url:"insertcomment.do",
			type:"post",
			data:data,
			success:function(res){
				alert(res);
			},
			error:function(error){
				alert("error : " + error);
			}
		});
	} */
	
	/* function deleteComment(){
		if($("#formInstID").val()=="" || $("#UR_Code").val()=="")
		{	alert("forminstid, urcode need"); return false; }
		
		var data = {
				"formInstID":$("#formInstID").val(),
				"userID":$("#UR_Code").val(),
		}
		
		$.ajax({
			url:"deletecomment.do",
			type:"post",
			data:data,
			success:function(res){
				alert(res);
			},
			error:function(error){
				alert("error : " + error);
			}
		});
	} */
	
	/* function getComment(){
		if($("#formInstID").val()=="")
		{	alert("forminstid need urcode option"); return false; }
		
		var data = {
				"formInstID":$("#formInstID").val(),
		}
		
		if($("#UR_Code").val() != ""){
			data["userID"] = $("#UR_Code").val();
		}
		
		$.ajax({
			url:"getcomment.do",
			type:"post",
			data:data,
			success:function(res){
				alert(Object.toJSON(res));
			},
			error:function(error){
				alert("error : " + error);
			}
		});
	} */
	
	function openFormDraft(){
		CFN_OpenWindow("approval_Form.do?formID=11&mode=DRAFT", "", 790, (window.screen.height - 100), "resize");
	}
	
	function openFormList(){
		CFN_OpenWindow("approval_Form.do?mode=APPROVAL&processID=30&workitemID=84&performerID=84&processdescriptionID=31&userCode=baejh&gloct=APPROVAL&admintype=&archived=false&usisdocmanager=true&subkind=T000", "", 790, (window.screen.height - 100), "resize");
	}
	
	function test(){
		var data = {
				
		}
		$.ajax({
			//url:"http://localhost:8080/covicore/test11.do",
			type:"post",
			data:data,
			success:function(res){
				alert(res.status)
			},
			error:function(error){
			
			}
		});
		
		
	}
	
	function SFTPTEST(){
		var data = {
				
		}
		$.ajax({
			//url:"http://localhost:8080/covicore/test12.do",
			type:"post",
			data:data,
			success:function(res){
				alert(res.status)
			},
			error:function(error){
			
			}
		});
		
		
	}
	
	function oauth(){
		CFN_OpenWindow("oauth.do", "", 790, (window.screen.height - 100), "resize");
		
	}
	
	function oauthGoogle(){
		CFN_OpenWindow("oauth2/google.do", "", 790, (window.screen.height - 100), "resize");
	} 
	
	function abc(){
		var data = {
				
		}
		$.ajax({
			url:"http://192.168.11.126:8080/covicore/basecode/get.do",
			type:"post",
			data:data,
			success:function(res){
				alert(res.status);
			},
			error:function(error){
			
			}
		});
	}
	
	/* renderAjaxSelect : function(initInfos, oncomplete, lang){
		alert("a");
		$.ajax({
			type:"POST",
			data:{
				"codeGroups" : coviCtrl.makeCodeGroups(initInfos)
			},
			url:"http://192.168.11.126:8080/covicore/basecode/get.do",
			success:function (data) {  */
	
</script>
<h3 class="con_tit_box">
	<span class="con_tit">test페이지입니다.</span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a class="set_box" onclick="setFirstPageURL()">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<div id="API_TEST">
	<form id="form1">
	<div id="FormTest">
		<input type="button" class="AXButton"  id="formtestbtn" value="양식 테스트(기안)" onclick="openFormDraft();" />&nbsp;&nbsp;
		<input type="button" class="AXButton"  id="formtestbtn" value="양식 테스트(함)" onclick="openFormList();" />&nbsp;&nbsp;
<!-- 		<input type="button" class="AXButton"  value="SAML Logout" onclick="test();" />&nbsp;&nbsp;
		<input type="button" class="AXButton"  value="SFTP" onclick="SFTPTEST();" />&nbsp;&nbsp; -->
		<input type="button" class="AXButton" value="OAuth" onclick="oauth(); return false;"/>&nbsp;&nbsp;
		<input type="button" class="AXButton" value="Google OAuth" onclick="oauthGoogle(); return false;"/>
		<!-- <input type="button" class="AXButton" value="OAuth" onclick="abc(); return false;"/> -->
	</div>
	<br/>
	<div id="test">
	
		<table style="width:100%;height:500px;border: 1px solid black">
			<tr style="height:50px">
				<td style="width:20%">
					<!-- <input type="button" class="AXButton" value="암호확인" onclick="chkPassword(); return false;"/> -->
				</td>
				<td style="width:80%" colspan=2>
					<input type="text" id="txtPwd">
				</td>
			</tr>
			<tr>
				<td style="width:20%">
					<input type="button" class="AXButton" value="draft/approval" onclick="draft(); return false;"/><br/>
					<input type="button" class="AXButton" value="abort" onclick="abort(); return false;"/>
				</td>
				<td style="width:40%">
					입력
					<textarea id="txt1" style="width:100%;height:90%;resize:none;overflow:scroll"></textarea>
				</td>
				<td style="width:40%">
					출력
					<textarea id="txt2" style="width:100%;height:90%;resize:none;overflow:scroll"></textarea>
				</td>
			</tr>
		</table>
		
		<table style="width:100%;height:200px;border: 1px solid black">
			<tr style="height:50px">
				<td style="width:20%">
					<!-- <input type="button" class="AXButton" value="코멘트추가" onclick="insertComment(); return false;"/>
					<input type="button" class="AXButton" value="코멘트업데이트" onclick="insertComment(); return false;"/> -->
					<!-- <input type="button" class="AXButton" value="코멘트삭제" onclick="deleteComment(); return false;"/> -->
					<!-- <input type="button" class="AXButton" value="코멘트가져오기(전체)" onclick="getComment(); return false;"/> -->
					<!-- <input type="button" class="AXButton" value="코멘트가져오기" onclick="getComment(); return false;"/> -->
				</td>
				<td style="width:80%;border: 1px solid black" colspan=2 >
					<span>&nbsp;&nbsp;forminstid : </span><input type="text" id="formInstID"><br/>
					<span>&nbsp;&nbsp;urcode : </span><input type="text" id="UR_Code"><br/>
					<span>&nbsp;&nbsp;urname : </span><input type="text" id="UR_Name"><br/>
					<span>&nbsp;&nbsp;mode : </span><input type="text" id="mode"><br/>
					<span>&nbsp;&nbsp;kind : </span><input type="text" id="kind"><br/>
					<span>&nbsp;&nbsp;comment : </span><input type="text" id="comment"><br/>
				</td>
			</tr>
		</table>
	</div>
	</form>
</div>