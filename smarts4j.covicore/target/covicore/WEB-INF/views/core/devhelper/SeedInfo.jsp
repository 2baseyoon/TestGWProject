<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
table {
    border-collapse: collapse;
}
table, th, td {
    border: 1px solid black;
    padding: 3px;
}
</style>

<h3 class="con_tit_box">
    <span class="con_tit">개발지원-기초정보조회</span>
</h3>

<table>
	<tr>
		<th>Algorithm</th>
		<th>Origin</th>
		<th>Action</th>
		<th>Encrypted</th>
	</tr>
	<tr>
		<td>SEED</td>
		<td><textarea id="txtSEEDOrigin" style="width:350px;height:100px;"></textarea></td>
		<td>
			<input type="button" class="AXButton" onclick="encrypt('SEED'); return false;" value="--> encrypt">
			<br/>
			<input type="button" class="AXButton" onclick="decrypt('SEED'); return false;" value="<-- decrypt">
		</td>
		<td><textarea id="txtSEEDEncrypted" style="width:350px;height:100px;"></textarea></td>
	</tr>
</table>
<br/>
	
<script type="text/javascript">

function encrypt(alg){
	
	var txt = $('#txt' + alg + 'Origin').val()
	
	if(txt != null && txt != ''){
		$.ajax({
			url:"/covicore/devhelper/encrypt.do",
				type:"post",
				data:{
					"algorithm" : alg,
					"text" : txt
				},
				success: function (res) {
					if(res.status == 'SUCCESS' && res.result != ''){
						$('#txt' + alg + 'Encrypted').val(res.result);
					}
				},
				error : function (error){
					Common.Error(error);
				}
			});	
	}
}

function decrypt(alg){
	
	var txt = $('#txt' + alg + 'Encrypted').val()
	
	if(txt != null && txt != ''){
		$.ajax({
			url:"/covicore/devhelper/decrypt.do",
				type:"post",
				data:{
					"algorithm" : alg,
					"text" : txt
				},
				success: function (res) {
					if(res.status == 'SUCCESS' && res.result != ''){
						$('#txt' + alg + 'Origin').val(res.result);
					}
				},
				error : function (error){
					Common.Error(error);
				}
			});	
	}
}

</script>
	