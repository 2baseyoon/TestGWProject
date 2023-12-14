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
    <a href="#" class="set_box">
    	<span class="set_initialpage"><p>초기 페이지로 설정</p></span>
    </a>
</h3>

<table>
	<tr>
		<th>Algorithm</th>
		<th>Origin</th>
		<th>Action</th>
		<th>Encrypted</th>
	</tr>
	<tr>
		<td>PBE</td>
		<td><textarea id="txtPBEOrigin" style="width:350px;height:100px;"></textarea></td>
		<td>
			<input type="button" class="AXButton" onclick="encrypt('PBE'); return false;" value="--> encrypt">
			<br/>
			<input type="button" class="AXButton" onclick="decrypt('PBE'); return false;" value="<-- decrypt">
		</td>
		<td><textarea id="txtPBEEncrypted" style="width:350px;height:100px;"></textarea></td>
	</tr>
	<tr>
		<td>AES</td>
		<td><textarea id="txtAESOrigin" style="width:350px;height:100px;"></textarea></td>
		<td>
			<input type="button" class="AXButton" onclick="encrypt('AES'); return false;" value="--> encrypt">
			<br/>
			<input type="button" class="AXButton" onclick="decrypt('AES'); return false;" value="<-- decrypt">
		</td>
		<td><textarea id="txtAESEncrypted" style="width:350px;height:100px;"></textarea></td>
	</tr>
	<tr style="display:none">
		<td>MD5</td>
		<td><textarea id="txtMD5Origin" style="width:350px;height:100px;"></textarea></td>
		<td>
			<input type="button" class="AXButton" onclick="encrypt('MD5'); return false;" value="--> encrypt">
		</td>
		<td><textarea id="txtMD5Encrypted" style="width:350px;height:100px;"></textarea></td>
	</tr>
	<tr>
		<td>SEED</td>
		<td><textarea id="txtSEEDOrigin" style="width:350px;height:100px;"></textarea></td>
		<td>
			<input type="button" class="AXButton" onclick="encrypt('SEED'); return false;" value="--> encrypt">
		</td>
		<td><textarea id="txtSEEDEncrypted" style="width:350px;height:100px;"></textarea></td>
	</tr>
	<tr>
		<td>BASE64</td>
		<td><textarea id="txtBASEOrigin" style="width:350px;height:100px;"></textarea></td>
		<td>
			<input type="button" class="AXButton" onclick="encrypt('BASE'); return false;" value="--> encrypt">
			<br/>
			<input type="button" class="AXButton" onclick="decrypt('BASE'); return false;" value="<-- decrypt">
		</td>
		<td><textarea id="txtBASEEncrypted" style="width:350px;height:100px;"></textarea></td>
	</tr>
</table>
<br/>
<table>
	<tr id="trDomain">
		<th>Domain</th>
		<td><input type="text" class="AXInput" id="txtDomain"></td>
	</tr>
	<tr id="trExpireDate">
		<th>ExpireDate</th>
		<td><input type="text" class="AXInput" id="txtExpireDate"></td>
	</tr>
	<tr id="trUserCount">
		<th>UserCount</th>
		<td><input type="text" class="AXInput" id="txtUserCount"></td>
	</tr>
</table>
<input type="button" class="AXButton" onclick="makeLicense(); return false;" value="라이선스 값 생성">
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

function makeLicense(){
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
	
	/*
	$.ajax({
		url:"/covicore/cache/remove.do",
			type:"post",
			data:{
				"cacheType" : $("#selCacheType option:selected").val(),
				"domainID" : $('#txtDomainID').val(),
				"codeGroup" : $('#txtCodeGroup').val(),
				"code" : $('#txtCode').val()
			},
			success: function (res) {
				Common.Error(res.status);
			},
			error : function (error){
				Common.Error(error);
			}
		});
	*/
}

</script>
	