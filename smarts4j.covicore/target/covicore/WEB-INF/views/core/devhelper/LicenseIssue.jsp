<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
table {
    border-collapse: collapse;
}
table, th, td {
    border: 1px solid black;
    padding: 5px;
    margin:10px
}
th{background-color:#F2F2F2}
textarea {width:95%}
input[type="text"] {width:95%}
</style>

<h3 class="con_tit_box">
    <span class="con_tit">라이선스 발급</span>
</h3>

<table>
	<tr>
		<th></th>
		<th>Origin</th>
		<th>Action</th>
		<th>Encrypted</th>
	</tr>
	<tr>
		<th>baseframework 4.5 이전</th>
		<td><textarea id="txtPBEOrigin" style="width:350px;height:100px;"></textarea></td>
		<td>
			<input type="button" class="AXButton" onclick="encrypt('PBE'); return false;" value="--> encrypt">
			<br/>
			<input type="button" class="AXButton" onclick="decrypt('PBE'); return false;" value="<-- decrypt">
		</td>
		<td><textarea id="txtPBEEncrypted" style="width:350px;height:100px;"></textarea></td>
	</tr>
</table>
<br/>
<table width=100%>
	<tr>
		<th colspan=3  style="color:red">baseframework 4.5 이후(ENC 없이 세팅하기)</th>
	</tr>
	<tr>
		<th style="widht:100px">대표사이트</th>
		<td colspan=2><input type="text" id="domainUrl"></td>

	</tr>
	<tr>
		<th>도메인</th>
		<td><textarea type="text" id="domain" rows=5></textarea></td>
		<td><textarea type="text" id="LIUD" rows=5></textarea></td>
	</tr>
	<tr>
		<th>공식사용자수</th>
		<td><input type="text" id="userCount"></td>
		<td><input type="text" id="LIUC"></td>
	</tr>
	<tr>
		<th>공식시간</th>
		<td><input type="text" id="expireDate"></td>
		<td><input type="text" id="LIUP"></td>
	</tr>
	<tr>
		<th>임시사용자수</th>
		<td><input type="text" id="exUserCount"></td>
		<td><input type="text" id="LIExUC"></td>
	</tr>
	<tr>
		<th>임시사용기간</th>
		<td><input type="text" id="ex1Date"></td>
		<td><input type="text" id="LIEx1UP"></td>
	</tr>
</table>
<input type="button" class="AXButton" onclick="encryptLicense(); return false;" value="라이선스 값 생성">
<input type="button" class="AXButton" onclick="decryptLicense(); return false;" value="라이선스 값 복원">
<br/>
<div id="con_license"></div>
	
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

function encryptLicense(){
	$.ajax({
		url:"/covicore/devhelper/encryptLicense.do",
			type:"post",
			data:{
				"domainUrl" : $("#domainUrl").val(),
				"domain" : $('#domain').val(),
				"userCount" : $('#userCount').val(),
				"expireDate" : $('#expireDate').val(),
				"exUserCount" : $('#exUserCount').val(),
				"ex1Date" : $('#ex1Date').val(),
			},
			success: function (json) {
				if (json.status == "SUCCESS"){
					$('#LIUD').val(json.result.LIUD);
					$('#LIUC').val(json.result.LIUC);
					$('#LIUP').val(json.result.LIUP);
					$('#LIExUC').val(json.result.LIExUC);
					$('#LIEx1UP').val(json.result.LIEx1UP);
					
				}else{
					Common.Error(json.status);
				}
			},
			error : function (error){
				Common.Error(error);
			}
		});
}
function decryptLicense(){
	$.ajax({
		url:"/covicore/devhelper/decryptLicense.do",
			type:"post",
			data:{
				"domainUrl" : $("#domainUrl").val(),
				"LIUD" : $('#LIUD').val(),
				"LIUC" : $('#LIUC').val(),
				"LIUP" : $('#LIUP').val(),
				"LIExUC" : $('#LIExUC').val(),
				"LIEx1UP" : $('#LIEx1UP').val(),
			},
			success: function (json) {
				if (json.status == "SUCCESS"){
					$('#domain').val(json.result.domain);
					$('#userCount').val(json.result.userCount);
					$('#expireDate').val(json.result.expireDate);
					$('#exUserCount').val(json.result.exUserCount);
					$('#ex1Date').val(json.result.ex1Date);
					
				}else{
					Common.Error(json.status);
				}
			},
			error : function (error){
				Common.Error(error);
			}
		});
	

}


	
	/*
	1. License key prop
         도메인 - <add key="LIUD" value="trmg3Wb7+FOD8QJXbCV3FiFDSj20GQbLeHVTc223IR4/HDrCfVDtKFX94CkVgYwYiaoWrY+QZ5odlvaE+bXTIQVOtcZ3qj0tRA/X3Nts32Oe485lCdG4PXstRf/n2Qp5"/>
         사용자 수 - <add key="LIUC" value="oZY/G7MATfQ="/>
         만료기한 - <add key="LIUP" value="RXBzJPoJUKG70mxVwXYnnw=="/>
         임시 사용자 수 - <add key="LIExUC" value="Rh4WYRm5E1EfmDgdHwB4kw=="/>
    1차 임시 만료기한 - <add key="LIEx1UP" value="Kq3VcJtc8pr1y23C7aFtXp4OGzPuy3JJ"/>
    2차 임시 만료기한 - <add key="LIEX2UP" value="tn6FJnKOiTrgqc8g9aMJc8O7xkcR+dii"/>
         키값 - <add key="Secure_Key" value="77, 6F, 72, 6B, 70, 6C, 61, 63, 65, 32, 2E, 30, 63, 6F, 6E, 6E"/>
         파라미터 키값 - <add key="PSecure_Key" value="77, 6F, 72, 6B, 70, 6C, 61, 63, 65, 32, 2E, 30, 63, 6F, 6E, 6E"/>
    x 키값 - <add key="XSecure_Key" value="43, 6F, 76, 69, 2E, 46, 72, 61, 6D, 65, 77, 6F, 72, 6B, 56, 32"/>
    
    
    
	
	*/
	


</script>
	