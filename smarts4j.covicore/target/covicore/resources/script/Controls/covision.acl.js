/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2017.06.19</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///권한지정 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/

var g_aclVariables = {
		lang : "ko",
		dictionary : { 
				confirm : '확인;Check;确认;确认;;;;;;',
				cancel : '취소;Cancel;キャンセル;取消;;;;;;',
				add : '추가;Add;追加;追加;;;;;;',
				del : '삭제;Delete;削除;删除;;;;;;',
				allow : '허용;allow;許容;容许;;;;;;',
				reject : '거부;reject;拒否;否决;;;;;;',
				lbl_DeptOrgMap : '권한지정;Permission Setting;権限の指定;权限指定;;;;;;',
				security : '보안;Security;セキュリティー;保安;;;;;;',
				create : '생성;Creation;生成;生成;;;;;;',
				modify : '수정;Modify;修整;修整;;;;;;',
				execute : '실행;Execute;実行;实行;;;;;;',
				view : '조회;View;照会;查询;;;;;;',
				read : '읽기;Reading;読み;阅读;;;;;;;',
				all : '권한 전체 허용;Allow Full Permission;権限の全て許可;权利全部容许;;;;;;',
				msg_checkAuth : '사용권한을 설정하여 주십시오.;Please set permission.;使用権限を設定してください;请设置使用权限;;;;;;;',
				msg_checkDel : '선택한 항목을 삭제하시겠습니까?;Are you sure you want to delete the selected item?;選択した項目を削除しますか;确定要删除选择的项目吗?;;;;;;',
				auth : '권한;authority;権限;权限;;;;;;',
				community : '커뮤니티;commnunity;共同体;社区;;;;;;',
				company : '회사;company;会社;公司;;;;;;;',
				jobLevel : '직급;position;職級;职级;;;;;;',
				jobPosition : '직위;Position;職位;职位;;;;;;',
				jobTitle : '직책;official responsibilities;職責;职责;;;;;;',
				manage : '관리;manager;支配人;经理;;;;;;',
				officer : '임원;Executive;役員;管理人员;;;;;;;',
				dept : '부서;Department;部署;部门;;;;;;',
				user : '사용자;User;使用者;用户;;;;;;',
				group : '그룹;Group;グループ;集团;;;;;;',
				inherited : '상속;Inherit;継承;继承;;;;;;',
				inherit_folder_permissions : '폴더권한상속;Inherit folder permissions;フォルダ権限の継承。;繼承文件夾權限;;;;;;',
				inherit_permissions : '상위권한상속;Inherit parent permissions;親のアクセス許可を継承します。;继承父的权限;;;;;;',
				subfolderApply : '하위 객체 권한 모두 변경;Change all child object permissions;サブオブジェクト権限のすべての変更;更改子对象的所有权限;;;;;;',
				msg_inheritedDel: '상속 받고 있는 권한은 삭제할 수 없습니다. 상속을 해제 하여 주십시요.;You cannot delete inherited permissions. Please release the inheritance.;継承している権限は削除できません。 相続を解除してください。;继承的权限不能删除。 请解除继承。;;;;;;',
				subInclude : '하위포함;Sub Include;下位含む;包含子对象;;;;;;',
				subIncludeAllow : '포함;Including;砲艦;包括;;;;;;',
				subIncludeReject : '미포함;Not included;含まない;未包括;;;;;;',
				change : '변경;Change;変更;边疆;;;;;;',
				aclChange : '권한변경 이력;History;権限変更履歴;权限变更履历;;;;;;',
				gubun : '구분;Sort;区分;区分;;;;;;',
				name : '구분;Name;名前;名称;;;;;;',
				s : '보안;S;セキュリティー;保安;;;;;;',
				c : '생성;C;生成;生成;;;;;;',
				d : '삭제;D;削除;删除;;;;;;',
				m : '수정;M;修整;修整;;;;;;',
				e : '실행;E;実行;实行;;;;;;',
				v : '조회;V;照会;查询;;;;;;',
				r : '읽기;R;読み;阅读;;;;;;;'	
		}
};

/**
 * 권한지정 컨트롤 생성자
 */
function CoviACL(opt){
	//설정
	this.config = {
			target : '',
			lang : 'ko',
			hasButton : 'true',
			allowedACL : 'SCDMEVR',
			orgMapCallback : '',
			aclCallback : '',
			useInherited : false,		// 상위권한 상속
			useUpdateChildren: 'N',		// 하위객체(메뉴,폴더,커뮤니티,포탈,웹파트) 일괄적용 기능 사용여부
			inheritedFunc : '',			
			initialACL : 'SCDMEVR',
			initSubInclude : 'Y',		// ACL을 그룹에 부여하는 경우, 하위 그룹의 모든 사용자에게 적용여부의 기본값
			systemType : 'Board',
			objectID : '',
			objectType : ''
	}
	
	if(!this.isEmpty(opt.lang)){
		this.config.lang = opt.lang;	
	}
		
	if(!this.isEmpty(opt.hasButton)){
		this.config.hasButton = opt.hasButton;	
	}
	
	if(!this.isEmpty(opt.allowedACL)){
		this.config.allowedACL = opt.allowedACL;	
	}
		
	if(!this.isEmpty(opt.orgMapCallback)){
		this.config.orgMapCallback = opt.orgMapCallback;	
	}
	
	if(!this.isEmpty(opt.aclCallback)){
		this.config.aclCallback = opt.aclCallback;	
	}
	
	if(!this.isEmpty(opt.useInherited)){
		this.config.useInherited = opt.useInherited;
	}
	
	if(!this.isEmpty(opt.inheritedFunc)){
		this.config.inheritedFunc = opt.inheritedFunc;
	}
	
	if(!this.isEmpty(opt.initialACL)){
		this.config.initialACL = opt.initialACL;
	}
	
	if(!this.isEmpty(opt.initSubInclude)){
		this.config.initSubInclude = opt.initSubInclude;
	}
	
	if(!this.isEmpty(opt.useUpdateChildren)){
		this.config.useUpdateChildren = opt.useUpdateChildren;
	}
	
	if(!this.isEmpty(opt.systemType)){
		this.config.systemType = opt.systemType;
	}
	
	if(!this.isEmpty(opt.objectID)){
		this.config.objectID = opt.objectID;
	}
	
	if(!this.isEmpty(opt.objectType)){
		this.config.objectType = opt.objectType;
	}
}

/**
 * 빈값 체크
 * @param value
 * @returns {Boolean}
 */
CoviACL.prototype.isEmpty = function(value){
  return (value == null || value.length === 0);
}

/**
 * 권한컨트롤 생성
 * @returns {String}
 */
CoviACL.prototype.render = function(target){
	var $this = this;
	
	//taget 재정의
	$this.config.target = target;	
	coviCmn.aclVariables[$this.config.target] = [];
	coviCmn.aclActionTable[$this.config.target] = [];
	coviCmn.aclBeforeVariables = "";
	
	//set locale
	var sessionLang = Common.getSession("lang");
	if(typeof sessionLang != "undefined" && sessionLang != ""){
		g_aclVariables.lang = sessionLang;
	}
	
	var html = '';
	html += '<div class="authSetting_top">';
	
	if(Common.getDic("lbl_inheritedTooltip") != "lbl_inheritedTooltip" && $this.config.systemType != "Message" && $this.config.systemType != "Schedule") {
		html += '	<span style="float: left; margin-top: 10px;" >';
		html += '		<font color="red">' + Common.getDic("lbl_inheritedTooltip") + '</font>';
		html += '	</span>';
	}
	
	if ($this.config.useInherited){		
		html += '	<span style="chkStyle01">';
		html += '		<input id="' + $this.config.target + '_isInherited" type="checkbox">';
		html += '		<label for="' + $this.config.target + '_isInherited">' + CFN_GetDicInfo($this.config.systemType != "Message" ? g_aclVariables.dictionary.inherit_permissions : g_aclVariables.dictionary.inherit_folder_permissions, g_aclVariables.lang) + '</label>'; // 상위권한상속
		html += '	</span>';
	}
	
	html += '	<a href="javascript:void(0);" class="btnTypeDefault" id="' + $this.config.target + '_btnCallOrgMap">' + CFN_GetDicInfo(g_aclVariables.dictionary.add, g_aclVariables.lang) + '</a>';
	
	if($this.config.objectID != "" && $this.config.objectType != "") {
		html += '	<a href="javascript:void(0);" class="btnTypeDefault" id="' + $this.config.target + '_btnAclHistory">' + CFN_GetDicInfo(g_aclVariables.dictionary.aclChange, g_aclVariables.lang) + '</a>';
	}
	
	html += '</div>';	
	html += '<div class="authPermissions">';	
	html += '<div id="' + $this.config.target + '_divPermissions" class="userlist">';
	html += '	<table id="' + $this.config.target + '_hTblPermissions">';
	html += '		<colgroup>';
	html += '			<col width="100px" />';
	html += '			<col width="60px" />';
	html += '			<col width="50px" />';
	for (var x = 0; x < $this.config.allowedACL.length; x++)
		if ($this.config.allowedACL.charAt(x) != "_"){
		html += '			<col />';
	}
	html += '			<col width="80px" />';
	html += '			<col width="40px" />';
	html += '		</colgroup>';
	html += '		<thead class="thead" id="' + $this.config.target + '_hThdPermissions"> <!--소유회사 -->';			
	html += '			<tr style="background-color: #fff;">';
	html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.name, g_aclVariables.lang) + '</td>';
	html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.gubun, g_aclVariables.lang) + '</td>';
	html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.inherited, g_aclVariables.lang) + '</td>';
	if ($this.config.allowedACL.charAt(0) != "_") html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.s, g_aclVariables.lang) + '</td>';
	if ($this.config.allowedACL.charAt(1) != "_") html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.c, g_aclVariables.lang) + '</td>';
	if ($this.config.allowedACL.charAt(2) != "_") html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.d, g_aclVariables.lang) + '</td>';
	if ($this.config.allowedACL.charAt(3) != "_") html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.m, g_aclVariables.lang) + '</td>';
	if ($this.config.allowedACL.charAt(4) != "_") html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.e, g_aclVariables.lang) + '</td>';
	if ($this.config.allowedACL.charAt(5) != "_") html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.v, g_aclVariables.lang) + '</td>';
	if ($this.config.allowedACL.charAt(6) != "_") html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.r, g_aclVariables.lang) + '</td>';
	html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.subInclude, g_aclVariables.lang) + '</td>';
	html += '				<td>' + CFN_GetDicInfo(g_aclVariables.dictionary.del, g_aclVariables.lang) + '</td>';
	html += '			</tr>';
	html += '		</thead>';	
	html += '		<tbody id="' + $this.config.target + '_hTbdPermissions"></tbody> <!--소유회사 이외 -->';
	html += '	</table>';
	html += '</div>';
	html += '</div>';
	html += '<table id="' + $this.config.target + '_hTblAcl" class="ca_table authSetting_bottom" style="border-collapse: collapse; margin-bottom: 10px;">';
	html += '	<colgroup>';
	html += '		<col width="20%" />';
	html += '		<col width="30%" />';
	html += '		<col width="20%" />';
	html += '		<col width="30%" />';
	html += '	</colgroup>';
	html += '	<tr>';
	html += '		<th>';
	html += 			CFN_GetDicInfo(g_aclVariables.dictionary.security, g_aclVariables.lang);
	html += '			<div class="collabo_help02">';
	html += '				<a href="javascript:void(0);" class="help_ico" id="btn_security_tt"></a>';
	html += '			</div>';
	html += '		</th>';
	html += '		<td>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_S_1" name="ACL_S" value="S" disabled/>';
	html += '				<label for="radio_ACL_S_1">' + CFN_GetDicInfo(g_aclVariables.dictionary.allow, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_S_2" name="ACL_S" value="_" disabled/> ';
	html += '				<label for="radio_ACL_S_2">' + CFN_GetDicInfo(g_aclVariables.dictionary.reject, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '		</td>';
	html += '		<th>';
	html += 			CFN_GetDicInfo(g_aclVariables.dictionary.create, g_aclVariables.lang);
	html += '			<div class="collabo_help02">';
	html += '				<a href="javascript:void(0);" class="help_ico" id="btn_create_tt"></a>';
	html += '			</div>';
	html += '		</th>';
	html += '		<td>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_C_1" name="ACL_C" value="C" disabled/>';
	html += '				<label for="radio_ACL_C_1">' + CFN_GetDicInfo(g_aclVariables.dictionary.allow, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_C_2" name="ACL_C" value="_" disabled/>';
	html += '				<label for="radio_ACL_C_2">' + CFN_GetDicInfo(g_aclVariables.dictionary.reject, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '		</td>';
	html += '	</tr>';
	html += '	<tr>';
	html += '		<th>';
	html += 			CFN_GetDicInfo(g_aclVariables.dictionary.del, g_aclVariables.lang);
	html += '			<div class="collabo_help02">';
	html += '				<a href="javascript:void(0);" class="help_ico" id="btn_del_tt"></a>';
	html += '			</div>';
	html += '		</th>';
	html += '		<td>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_D_1" name="ACL_D" value="D" disabled/>';
	html += '				<label for="radio_ACL_D_1">' + CFN_GetDicInfo(g_aclVariables.dictionary.allow, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_D_2" name="ACL_D" value="_" disabled/>';
	html += '				<label for="radio_ACL_D_2">' + CFN_GetDicInfo(g_aclVariables.dictionary.reject, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '		</td>';
	html += '		<th>';
	html += 			CFN_GetDicInfo(g_aclVariables.dictionary.modify, g_aclVariables.lang);
	html += '			<div class="collabo_help02">';
	html += '				<a href="javascript:void(0);" class="help_ico" id="btn_modify_tt"></a>';
	html += '			</div>';
	html += '		</th>';
	html += '		<td>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_M_1" name="ACL_M" value="M" disabled/>';
	html += '				<label for="radio_ACL_M_1">' + CFN_GetDicInfo(g_aclVariables.dictionary.allow, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_M_2" name="ACL_M" value="_" disabled/>';
	html += '				<label for="radio_ACL_M_2">' + CFN_GetDicInfo(g_aclVariables.dictionary.reject, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '		</td>';
	html += '	</tr>';
	html += '	<tr>';
	html += '		<th>';
	html += 			CFN_GetDicInfo(g_aclVariables.dictionary.execute, g_aclVariables.lang);
	html += '			<div class="collabo_help02">';
	html += '				<a href="javascript:void(0);" class="help_ico" id="btn_execute_tt"></a>';
	html += '			</div>';
	html += '		</th>';
	html += '		<td>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_E_1" name="ACL_E" value="E" disabled/>';
	html += '				<label for="radio_ACL_E_1">' + CFN_GetDicInfo(g_aclVariables.dictionary.allow, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_E_2" name="ACL_E" value="_" disabled/>';
	html += '				<label for="radio_ACL_E_2">' + CFN_GetDicInfo(g_aclVariables.dictionary.reject, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '		</td>';
	html += '		<th>';
	html += 			CFN_GetDicInfo(g_aclVariables.dictionary.view, g_aclVariables.lang);
	html += '			<div class="collabo_help02">';
	html += '				<a href="javascript:void(0);" class="help_ico" id="btn_view_tt"></a>';
	html += '			</div>';
	html += '		</th>';
	html += '		<td>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_V_1" name="ACL_V" value="V" disabled/>';
	html += '				<label for="radio_ACL_V_1">' + CFN_GetDicInfo(g_aclVariables.dictionary.allow, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_V_2" name="ACL_V" value="_" disabled/>';
	html += '				<label for="radio_ACL_V_2">' + CFN_GetDicInfo(g_aclVariables.dictionary.reject, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '		</td>';
	html += '	</tr>';
	html += '	<tr>';
	html += '		<th>';
	html += 			CFN_GetDicInfo(g_aclVariables.dictionary.read, g_aclVariables.lang);
	html += '			<div class="collabo_help02">';
	html += '				<a href="javascript:void(0);" class="help_ico" id="btn_read_tt"></a>';
	html += '			</div>';
	html += '		</th>';
	html += '		<td>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_R_1" name="ACL_R" value="R" disabled/>';
	html += '				<label for="radio_ACL_R_1">' + CFN_GetDicInfo(g_aclVariables.dictionary.allow, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_ACL_R_2" name="ACL_R" value="_" disabled/>';
	html += '				<label for="radio_ACL_R_2">' + CFN_GetDicInfo(g_aclVariables.dictionary.reject, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '		</td>';
	html += '		<th class="area_SubInclude">';
	html += 			CFN_GetDicInfo(g_aclVariables.dictionary.subInclude, g_aclVariables.lang);
	html += '			<div class="collabo_help02">';
	html += '				<a href="javascript:void(0);" class="help_ico" id="btn_subInclude_tt"></a>';
	html += '			</div>';
	html += '		</th>';
	html += '		<td class="area_SubInclude">';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_SubInclude_1" name="SubInclude" value="Y" disabled/>';
	html += '				<label for="radio_SubInclude_1">' + CFN_GetDicInfo(g_aclVariables.dictionary.subIncludeAllow, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '			<div class="radioStyle05">';
	html += '				<input type="radio" id="radio_SubInclude_2" name="SubInclude" value="N" disabled/>';
	html += '				<label for="radio_SubInclude_2">' + CFN_GetDicInfo(g_aclVariables.dictionary.subIncludeReject, g_aclVariables.lang) + '</label>';
	html += '			</div>';
	html += '		</td>';
	html += '	</tr>';
	html += '</table>';
	
	if($this.config.hasButton == 'true' || $this.config.hasButton == true){
		html += '<div id="' + $this.config.target + '_divAllowedACL"></div>';
	}
	
	if($this.config.useUpdateChildren == "Y" && g_hasChild) {
		html += '<table id="' + $this.config.target + '_hTblAcl" class="ca_table authSetting_bottom" style="border-collapse: collapse; margin-top: 20px; margin-bottom: 10px;">';
		html += '	<colgroup>';
		html += '		<col width="35%" />';
		html += '		<col width="65%" />';
		html += '	</colgroup>';
		html += '	<tr>';
		html += '		<th>';
		html += 			CFN_GetDicInfo(g_aclVariables.dictionary.subfolderApply, g_aclVariables.lang);
		html += '			<div class="collabo_help02">';
		html += '				<a href="javascript:void(0);" class="help_ico" id="btn_subfolderApply_tt"></a>';
		html += '			</div>';
		html += '		</th>';
		html += '		<td>';
		html += '			<input type="checkbox" id="checkIsSubfolderInherited" name="isSubfolderInherited" value="Y" />  ' + CFN_GetDicInfo(g_aclVariables.dictionary.change, g_aclVariables.lang);
		html += '		</td>';
		html += '	</tr>';
		html += '</table>';
	}
	
	if($this.config.hasButton == 'true' || $this.config.hasButton == true){
		html += '<div id="' + $this.config.target + '_divControls">';
		html += '	<br />';
		html += '	<input type="button" id="' + $this.config.target + '_btnSetACL" value="' + CFN_GetDicInfo(g_aclVariables.dictionary.confirm, g_aclVariables.lang) + '" class="AXButtonSmall">';
		html += '	<input type="button" id="' + $this.config.target + '_btnCancel" value="' + CFN_GetDicInfo(g_aclVariables.dictionary.cancel, g_aclVariables.lang) + '" class="AXButtonSmall">';
		html += '</div>';	
	}
	
	html += '<div style="display: none;">';
	html += '<input type="hidden" id="hidACLInfo_Old" /> <!--수정 시 기존 데이터  -->';
	html += '<input type="hidden" id="hidACLInfo_Del" /> <!--실제 삭제될 데이터  -->';
	html += '<input type="hidden" id="hidACLInfo" />	<!--저장 될 데이터  -->';
	html += '</div>';
	
	//html += '<input type="checkbox" id="' + target + '_chkAll" value="Y" />&nbsp;메뉴 권한 전체 허용';
	
	$('#' + $this.config.target).html(html);
	
	//radio onchange 처리
	$('#' + target + '_hTblAcl input[type=radio]').change(function() {
		// ACL 추출
		var aclList = '';
		aclList += coviACL_getCharFromAclRadio(target, 'ACL_S');
		aclList += coviACL_getCharFromAclRadio(target, 'ACL_C');
		aclList += coviACL_getCharFromAclRadio(target, 'ACL_D');
		aclList += coviACL_getCharFromAclRadio(target, 'ACL_M');
		aclList += coviACL_getCharFromAclRadio(target, 'ACL_E');
		aclList += coviACL_getCharFromAclRadio(target, 'ACL_V');
		aclList += coviACL_getCharFromAclRadio(target, 'ACL_R');
		
		// 하위포함
		var isSubInclude = coviACL_getCharFromAclRadio(target, 'SubInclude');
		
		// Subject 추출
		$('#' + target + ' .aclSubject').each(function () {
			if($(this).attr("data-clicked") != undefined){
				coviACL_updateACLBySubject(target, $(this).attr("objectcode"), aclList, isSubInclude);
				
				// 사용하는 권한에 대해서만 그리드 스타일 처리
				var chkStr = ($this.config.allowedACL) ? $this.config.allowedACL.replace(/_/g, '') : "SCDMEVR";					
				for(var i = 0; i < chkStr.length; i++){
					if(aclList.indexOf(chkStr.substr(i, 1)) > -1) $(this).find("td:eq(" + (i + 3) + ")").children("span").prop("class","auth_allow");
					else $(this).find("td:eq(" + (i + 3) + ")").children("span").prop("class","auth_deny");
				}
				
				// 하위포함 여부에 대해서 그리드 스타일 처리
				if(isSubInclude == "Y") $(this).find("td:eq(" + (chkStr.length + 3) + ")").children("span").prop("class","auth_allow");
				else $(this).find("td:eq(" + (chkStr.length + 3) + ")").children("span").prop("class","auth_deny");
			}
	    });
    });
	
	//allowedACL 처리
	for (var x = 0; x < $this.config.allowedACL.length; x++) {
	    var c = $this.config.allowedACL.charAt(x);

	    if(c != '_'){
	    	$('#' + $this.config.target + '_hTblAcl input[name=ACL_' + c + ']').attr("disabled", false);
	    }else{
			$('#' + $this.config.target + '_hTblAcl td:eq('+x+')').hide();
			$('#' + $this.config.target + '_hTblAcl td:eq('+x+')').prev().hide();
	    }
	}

	//전체 허용 버튼 처리
	if($this.config.allowedACL == 'SCDMEVR'){
		$('#' + $this.config.target + '_divAllowedACL').prepend('<input type="checkbox" id="' + $this.config.target + '_chkAll" value="Y"  onclick=\"coviACL_checkAll(this)\" />&nbsp;' + CFN_GetDicInfo(g_aclVariables.dictionary.all, g_aclVariables.lang));
	}
	
	//조직도 호출
	$('#' + $this.config.target + '_btnCallOrgMap').click(function(){
		var option = {
				callBackFunc : $this.config.orgMapCallback,
				type:"D9",
				treeKind:"Group",
				checkboxRelationFixed:"true"
		};

		coviCmn.openOrgChartPopup(encodeURIComponent(CFN_GetDicInfo(g_aclVariables.dictionary.lbl_DeptOrgMap, g_aclVariables.lang)), "D9", option);
	});
	
	//확인 버튼 클릭
	$('#' + $this.config.target + '_btnSetACL').click(function(){
		//validation 추가
		var aclData = coviACL_getACLData($this.config.target).aclData;

	    if (aclData == '[]') {
	        parent.Common.Warning(CFN_GetDicInfo(g_aclVariables.dictionary.msg_checkAuth, g_aclVariables.lang), "Warning Dialog", function () { });   // 사용권한을 설정하여 주십시오.
	    } else {
			//callback method 호출
	    	if($this.config.aclCallback != null && $this.config.aclCallback != ''){
				if(window[$this.config.aclCallback] != undefined){
					window[$this.config.aclCallback](aclData);
				} else if(parent[$this.config.aclCallback] != undefined){
					parent[$this.config.aclCallback](aclData);
				} else if(opener[$this.config.aclCallback] != undefined){
					opener[$this.config.aclCallback](aclData);
				}
	    	}
	    }
	});
	
	// 상위권한상속 클릭
	$("#" + $this.config.target + "_isInherited").off("click").on("click", function(){
		if ($(this).prop("checked")) {
			// (new Function("return " + $this.config.inheritedFunc + "()"))();
			return coviCmn.callFnBasedNamespace($this.config.inheritedFunc);
		} else {
			// 모든 하이라이트 해제
			$('.aclSubject').css("background-color", "inherit");
			$('.aclSubject').removeAttr("data-clicked");
			
			var data = [];
			
			// 상속을 해제하고, 상속 ObjectID 삭제
			$(".inherited_label").each(function () {
				var $tr = $(this).parent().parent();
				
				// 상속 해제한 권한 하이라이트
				$tr.css("background-color", "");
				$tr.find("input[type='button']").show();
				
				var SubjectCode = $tr.attr("objectcode");
				$(coviCmn.aclVariables[$this.config.target]).each(function (i, item) {
					if(item.SubjectCode == SubjectCode) {
						item.InheritedObjectID = 0;
					}
				});
				
				$(this).remove();				
			});
		  
			// 상속이 아닌 경우 권한 선택 라디오버튼 활성화
			$("#" + coviACL.config.target + "_hTblAcl").find("input").prop("disabled", false);
			$("#" + coviACL.config.target + "_hTblAcl").find("label").css("opacity", "1");
			
			// 상속이 아닌 경우 권한 전체 허용 체크박스 활성화
			$("#" + coviACL.config.target + "_chkAll").prop("disabled", false);
			$("#" + coviACL.config.target + "_chkAll").parent().css("opacity", "1");
		} 
	});
	
	// 상위권한상속 클릭
	$("#checkIsSubfolderInherited").off("click").on("click", function(){
		if($("#checkIsSubfolderInherited").is(":checked")){
			Common.Inform(Common.getDic('msg_useAuthInherited')); 	// 현재 권한으로 하위 모든 객체의 권한이 모두 변경 됩니다.
        }
	});
	
	// 권한변경 이력 팝업 호출
	$('#' + $this.config.target + '_btnAclHistory').click(function(){
		parent.Common.open("", "ACLHistoryPopup", CFN_GetDicInfo(g_aclVariables.dictionary.aclChange, g_aclVariables.lang), "/covicore/log/goACLHistoryPopup.do?objectID="+$this.config.objectID+"&objectType="+$this.config.objectType+"&allowedACL="+$this.config.allowedACL,"1110px","580px","iframe",true,null,null,true); 
	});
	
	// 권한설명 툴팁 (시스템 타입에 따라 다름)
	Common.toolTip($("#btn_security_tt"), "ToolTip_" + $this.config.systemType + "_AuthSecurity", "width:310px");
	Common.toolTip($("#btn_create_tt"), "ToolTip_" + $this.config.systemType + "_AuthCreate", "width:310px");
	Common.toolTip($("#btn_del_tt"), "ToolTip_" + $this.config.systemType + "_AuthDelete", "width:310px");
	Common.toolTip($("#btn_modify_tt"), "ToolTip_" + $this.config.systemType + "_AuthModify", "width:310px");
	Common.toolTip($("#btn_execute_tt"), "ToolTip_" + $this.config.systemType + "_AuthExecute", "width:310px");
	Common.toolTip($("#btn_view_tt"), "ToolTip_" + $this.config.systemType + "_AuthView", "width:310px");
	Common.toolTip($("#btn_read_tt"), "ToolTip_" + $this.config.systemType + "_AuthRead", "width:310px");
	Common.toolTip($("#btn_subInclude_tt"), "ToolTip_SubInclude", "width:310px");
	Common.toolTip($("#btn_subfolderApply_tt"), "ToolTip_subfolderApply", "width:370px");
}

CoviACL.prototype.set = function(data){
	var $this = this;
	var sHTML = "";
	var aclList = "";
	
	coviCmn.aclVariables[$this.config.target] = data;
	coviCmn.aclBeforeVariables = JSON.stringify(data);
	
	//subject 영역 set
	$(data).each(function (i, item) {
		var subjectType = '';
		var subjectType_A = item.SubjectType;
		var subjectTypeText = '';
		
		switch (subjectType_A.toUpperCase()) {
			case "CM":
				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.company, g_aclVariables.lang);		//"회사";
				subjectType = "COMPANY";
				break;
			case "JL":
				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobLevel, g_aclVariables.lang);		//"직급";
				subjectType = "JOBLEVEL";
				break;
			case "JP":
				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobPosition, g_aclVariables.lang);	//"직위";
				subjectType = "JOBPOSITION";
				break;
			case "JT":
				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobTitle, g_aclVariables.lang);		//"직책";
				subjectType = "JOBTITLE";
				break;
			case "MN":
				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.manage, g_aclVariables.lang);		//"관리";
				subjectType = "MANAGE";
				break;
			case "OF":
				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.officer, g_aclVariables.lang);		//"임원";
				subjectType = "OFFICER";
				break;
			case "DEPT":
				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.dept, g_aclVariables.lang);			//"부서";
				subjectType = "DEPT";
				break;
			case "UR":
				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.user, g_aclVariables.lang);			//"사용자";
				subjectType = "USER";
				break;
			default:
				switch(item.GroupType.toUpperCase()){
		  			case "AUTHORITY":
		  				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.auth, g_aclVariables.lang);			//"권한";
		  				subjectType = "GROUP";
		                break;
		  			case "COMMUNITY":
		  				subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.community, g_aclVariables.lang);		//"커뮤니티";
		  				subjectType = "GROUP";
		                break;
		             case "JOBLEVEL":
		            	subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobLevel, g_aclVariables.lang);		//"직급";
		            	subjectType = "GROUP";
		                break;
		             case "JOBPOSITION":
		            	subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobPosition, g_aclVariables.lang);	//"직위";
		            	subjectType = "GROUP";
		                break;
		             case "JOBTITLE":
		            	subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobTitle, g_aclVariables.lang);		//"직책";
		            	subjectType = "GROUP";
		                break;
		             case "MANAGE":
		            	subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.manage, g_aclVariables.lang);		//"관리";
		            	subjectType = "GROUP";
		                break;
		             case "OFFICER":
		            	subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.officer, g_aclVariables.lang);		//"임원";
		            	subjectType = "GROUP";
		                break;
		             case "DEPT":
		            	subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.dept, g_aclVariables.lang);			//"부서";
		            	subjectType = "GROUP";
		                break;
		             default:
		            	subjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.group, g_aclVariables.lang);			//"그룹";
		             	subjectType = "GROUP";
		                break;
	         	}	
				break;
		}
		
		sHTML += coviACL_permissionRowAdd(
				$this.config.target,
				item.SubjectCode, 
				subjectType, 
				subjectType_A,
				"",
				item.SubjectName, 
				subjectTypeText, 
				"",
				item.InheritedObjectID && item.InheritedObjectID != "0" ? true : false,
				item.Security,
				item.Create,
				item.Delete,
				item.Modify,
				item.Execute,
				item.View,
				item.Read,
				$this.config.allowedACL,
				item.IsSubInclude
			);
	});

	$('#' + $this.config.target + '_hTbdPermissions').append(sHTML);
	
	//radio 영역 set
	if (data.length==0) return;
	
	aclList = data[0].AclList;
	coviACL_setACLRdo(aclList, 0, 'S', $this.config.target);
	coviACL_setACLRdo(aclList, 1, 'C', $this.config.target);
	coviACL_setACLRdo(aclList, 2, 'D', $this.config.target);
	coviACL_setACLRdo(aclList, 3, 'M', $this.config.target);
	coviACL_setACLRdo(aclList, 4, 'E', $this.config.target);
	coviACL_setACLRdo(aclList, 5, 'V', $this.config.target);
	coviACL_setACLRdo(aclList, 6, 'R', $this.config.target);	
	coviACL_setSubIncludeRdo(data[0].IsSubInclude, data[0].SubjectType, "SubInclude", $this.config.target);
	
	var $tr = $('.aclSubject');
	$tr.css("background-color", "inherit");
	$tr.removeAttr("data-clicked");	
	$tr.first().css("background-color", "#E0FFFF");
	$tr.first().attr("data-clicked", data[0].SubjectCode);
	
	// 상위 권한 상속 여부 체크
	if (g_isInherited) {
		$("#" + $this.config.target + "_isInherited").prop("checked", true);
	}
	
	// 현재 선택된 권한이 상속되어 있는지 체크
	if ($tr.first().find(".inherited_label").length > 0) {
		// 상속일 경우 권한 선택 라디오버튼 비활성화
		$("#" + $this.config.target + "_hTblAcl").find("input").prop("disabled", true);
		$("#" + $this.config.target + "_hTblAcl").find("label").css("opacity", "0.7");
		
		// 상속일 경우 권한 전체 허용 체크박스 비활성화
		$("#" + $this.config.target + "_chkAll").prop("disabled", true);
		$("#" + $this.config.target + "_chkAll").parent().css("opacity", "0.7");
	} else {
		// 상속이 아닌 경우 권한 선택 라디오버튼 활성화
		$("#" + $this.config.target + "_hTblAcl").find("input").prop("disabled", false);
		$("#" + $this.config.target + "_hTblAcl").find("label").css("opacity", "1");
		
		// 상속이 아닌 경우 권한 전체 허용 체크박스 활성화
		$("#" + $this.config.target + "_chkAll").prop("disabled", false);
		$("#" + $this.config.target + "_chkAll").parent().css("opacity", "1");	
	}
}

function coviACL_setACLRdo(aclList, index, char, target){
	$('#' + target + '_hTblAcl input[name=ACL_' + char + ']:input').removeAttr('checked');
	if(aclList[index] == char){
		$('#' + target + '_hTblAcl input[name=ACL_' + char + ']:input[value=' + char + ']').prop("checked", true);
	} else {
		$('#' + target + '_hTblAcl input[name=ACL_' + char + ']:input[value=_]').prop("checked", true);
	}
}

// 하위포함 여부 체크박스 세팅
function coviACL_setSubIncludeRdo(isSubInclude, subjectType_A, char, target){
	var $tr = $('#' + target + '_hTblAcl input[name=' + char + ']:input[value="Y"]').parent().parent().parent();
	
	if(subjectType_A.toUpperCase() == "UR") {
		$tr.find(".area_SubInclude").hide();
	} else {
		$tr.find(".area_SubInclude").show();
	}
	
	$('#' + target + '_hTblAcl input[name=' + char + ']:input').removeAttr('checked');
	
	if(isSubInclude == "Y" || subjectType_A.toUpperCase() == "UR"){
		$('#' + target + '_hTblAcl input[name=' + char + ']:input[value="Y"]').prop("checked", true);
	} else {
		$('#' + target + '_hTblAcl input[name=' + char + ']:input[value="N"]').prop("checked", true);
	}
}

function coviACL_getACLData(target){
	var aclOrgData = coviCmn.aclBeforeVariables != "" ? JSON.parse(coviCmn.aclBeforeVariables) : "";
	var aclData = coviCmn.aclVariables[target];
    
    var beforeAclData = new Array();
    $(aclOrgData).each(function(i, item) {
    	var aclObj = {
    		SubjectCode : item.SubjectCode,
 			SubjectType : item.SubjectType,
 			AclList : item.AclList,
 			InheritedObjectID : item.InheritedObjectID,
 			IsSubInclude : item.IsSubInclude
    	}    	
    	beforeAclData.push(aclObj);
    });
    
    var afterAclData = new Array();
    $(aclData).each(function(i, item) {
    	var aclObj = {
    		SubjectCode : item.SubjectCode,
 			SubjectType : item.SubjectType,
 			AclList : item.AclList,
 			InheritedObjectID : item.InheritedObjectID,
 			IsSubInclude : item.IsSubInclude
    	}    	
    	afterAclData.push(aclObj);
    });
    
    var e1 = Object.entries(beforeAclData).sort();
    var e2 = Object.entries(afterAclData).sort();    
    
    // 기존 권한 데이터와 변경 권한 데이터 비교
    var aclIsChange = JSON.stringify(e1) === JSON.stringify(e2);
    
    var returnData = new Object();    
    returnData.aclIsChange = aclIsChange == true ? "N" : "Y";
    returnData.aclData = JSON.stringify(coviCmn.aclVariables[target]);
    
	return returnData;
}

function coviACL_getACLActionData(target) {
	return JSON.stringify(coviCmn.aclActionTable[target]);
}

function coviACL_getCharFromAclRadio(target, name){
	var c = '_';
	var $acl = $('#' + target + '_hTblAcl input[name=' + name + ']');
	if($acl.is(':enabled') && $acl.is(':checked')) { 
         c = $('#' + target + '_hTblAcl input[name=' + name + ']:checked').val();
    }
	return c;
}

//삭제할 데이터를 보관함.
function coviACL_setDelInfo(pObjTR) {
	var Item = new Object();
	Item.AN =  pObjTR.attr("objectcode");
	Item.DN_Code = pObjTR.attr("dncode");
	Item.ObjectType_A = pObjTR.attr("objecttype_a");
	
	if(document.getElementById("hidACLInfo_Del").value == ''){
		var deleteItemInfos = new Object();
		deleteItemInfos.item = Item;
		document.getElementById("hidACLInfo_Del").value = JSON.stringify(deleteItemInfos);
	}else{
		var txtDeleteItemInfos = $.parseJSON(document.getElementById("hidACLInfo_Del").value);
		$$(txtDeleteItemInfos).append("item",Item);
		document.getElementById("hidACLInfo_Del").value = JSON.stringify(txtDeleteItemInfos)
	}
}

/**
 * 권한컨트롤 생성
 * @returns {String}
 */
CoviACL.prototype.addSubjectRow = function(orgData){
	var $this = this;
 	var sHTML = "";
    var sObjectType = "";
    var sObjectType_A = "";
    var sObjectTypeText = "";
    var sCode = "";
    var sDNCode = "";
    var sDisplayName = "";
    var bCheck = false;
	var permissionJSON = $.parseJSON(orgData);
	
	var isInHerited = permissionJSON.hasOwnProperty("isInHerited") && permissionJSON.isInHerited ? true : false; // 상속 여부
	var inheritedObjectID = permissionJSON.hasOwnProperty("inheritedObjectID") ? permissionJSON.inheritedObjectID : "0"; // 상속받은 오브젝트 아이디
	
  	$(permissionJSON.item).each(function (i, item) {
  		sObjectType = item.itemType
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.user, g_aclVariables.lang); // 사용자
  			sObjectType_A = "UR";
  			sCode = item.AN;									//UR_Code
  			sDNCode = item.DN_Code == null ? "" : item.DN_Code; //DN_Code
  			sDisplayName = CFN_GetDicInfo(item.DN, g_aclVariables.lang);
  		}else{ //그룹
  			switch(item.GroupType.toUpperCase()){
	  			case "AUTHORITY":
	                sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.auth, g_aclVariables.lang);//"권한";
	                sObjectType_A = "GR";
	                break;
	  			case "COMMUNITY":
	                sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.community, g_aclVariables.lang);//"커뮤니티";
	                sObjectType_A = "GR";
	                break;
	  			case "COMPANY":
	                 sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.company, g_aclVariables.lang);//"회사";
	                 sObjectType_A = "CM";
	                 break;
	             case "JOBLEVEL":
	                 sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobLevel, g_aclVariables.lang);//"직급";
	                 sObjectType_A = "GR";
	                 break;
	             case "JOBPOSITION":
	                 sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobPosition, g_aclVariables.lang);//"직위";
	                 sObjectType_A = "GR";
	                 break;
	             case "JOBTITLE":
	                 sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.jobTitle, g_aclVariables.lang);//"직책";
	                 sObjectType_A = "GR";
	                 break;
	             case "MANAGE":
	                 sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.manage, g_aclVariables.lang);//"관리";
	                 sObjectType_A = "GR";
	                 break;
	             case "OFFICER":
	                 sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.officer, g_aclVariables.lang);//"임원";
	                 sObjectType_A = "GR";
	                 break;
	             case "DEPT":
	                 sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.dept, g_aclVariables.lang);//"부서";
	                 sObjectType_A = "GR";
	                 break;
	             default:
	                 sObjectTypeText = CFN_GetDicInfo(g_aclVariables.dictionary.group, g_aclVariables.lang);//"그룹";
	                 sObjectType_A = "GR";
	                 break;
         	}
  		
  			sCode = item.AN;
  			sDNCode = item.DN_Code == null ? "" : item.DN_Code;
            sDisplayName = CFN_GetDicInfo(item.GroupName, g_aclVariables.lang);
  		}
  		 
         $('#' + $this.config.target + '_hTbdPermissions').children().each(function () {
             if (($(this).attr("objecttype").toUpperCase() == sObjectType.toUpperCase()) &&
                 ($(this).attr("objectcode") == sCode)) {
                 bCheck = true;
             }
         });

         sHTML += coviACL_permissionRowAdd($this.config.target, sCode, sObjectType, sObjectType_A, sDNCode, sDisplayName, sObjectTypeText, "", isInHerited,
						item.hasOwnProperty("Security") ? item.Security : $this.config.initialACL[0],
						item.hasOwnProperty("Create") ? item.Create : $this.config.initialACL[1],
						item.hasOwnProperty("Delete") ? item.Delete : $this.config.initialACL[2],
						item.hasOwnProperty("Modify") ? item.Modify : $this.config.initialACL[3],
						item.hasOwnProperty("Execute") ? item.Execute : $this.config.initialACL[4],
						item.hasOwnProperty("View") ? item.View : $this.config.initialACL[5],
						item.hasOwnProperty("Read") ? item.Read : $this.config.initialACL[6],
						$this.config.allowedACL,
						item.hasOwnProperty("IsSubInclude") ? item.IsSubInclude : $this.config.initSubInclude);
         
         //_intIndex++;
         var addedACL = {
        		SubjectCode : sCode,
        		SubjectType : sObjectType_A,
        		AclList : item.hasOwnProperty("AclList") ? item.AclList : $this.config.initialACL,
        		InheritedObjectID : inheritedObjectID,
        		IsSubInclude : item.hasOwnProperty("IsSubInclude") ? item.IsSubInclude : $this.config.initSubInclude
         };
         
         coviCmn.aclVariables[$this.config.target].push(addedACL);
         
         // action table insert
         var actionData = coviCmn.aclActionTable[$this.config.target];
         var isExist = false;
         $(actionData).each(function(i, item) {
        	 if(item.SubjectCode == sCode){
     			if(item.Action == "DEL") {
     				// 새로 지정된 권한초기값이 이전이랑 같진 않음
     				item.Action = "MOD";
     			}
     			isExist = true;		
     			return false;
        	 }
         });
     	
         if(!isExist) {
        	 var actionObj = {
        		SubjectCode : sCode,
     			SubjectType : sObjectType_A,
     			Action : "NEW"
        	 }     		
        	 actionData.push(actionObj);
         }
 	});
  	
  	if(isInHerited) {
  		$('#' + $this.config.target + '_hTbdPermissions').prepend(sHTML);
  	} else {
  		$('#' + $this.config.target + '_hTbdPermissions').append(sHTML);
  	}
}

//사용권한에 사용자/그룹을 추가하는 HTML을 생성합니다.
function coviACL_permissionRowAdd(target, pStrCode, pStrObjectType, pStrObjectType_A, pStrDNCode, pStrDisplayName, pStrObjectTypeText, pStrDisabled, pIsInherited,
							Security,
							Create,
							Delete,
							Modify,
							Execute,
							View,
							Read,
							allowedACL,
							pIsSubInclude) {
    var sHTML = "";    
    sHTML += "<tr class=\"aclSubject\" onclick=\"coviACL_clickSubject('" + target + "', this);return false;\" objectcode=\"" + pStrCode + "\" objecttype=\"" + pStrObjectType + "\" objecttype_a=\"" + pStrObjectType_A + "\" dncode=\"" + pStrDNCode + "\" displayname=\"" + pStrDisplayName + "\" objecttypetext=\"" + pStrObjectTypeText + "\" style=\"height: 35px;\">";
    sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
    sHTML +=        " " + pStrDisplayName ;
    sHTML +=    "</td>";
    sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">" + pStrObjectTypeText + "</td>";
    
    sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px; text-align: center;\">";
    
    if (pIsInherited) {
    	sHTML +=    "<span class='inherited_label' style='display: inline-block; background: #fff; border: 1px solid #f56868; border-radius: 3px; color: #f56868; vertical-align: bottom; height: 19px; line-height: 17px; font-size: 12px; width: auto; text-indent: 0;'>" + CFN_GetDicInfo(g_aclVariables.dictionary.inherited, g_aclVariables.lang) + "</span>";
    }
    
    sHTML +=    "</td>";
    
	if (allowedACL.charAt(0) != "_"){ 
		if(Security == "_") 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_deny' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 0, this); return false;\"></span></td>";
		else 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_allow' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 0, this); return false;\"></span></td>";
	}
	
	if (allowedACL.charAt(1) != "_"){ 
		if(Create == "_") 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_deny' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 1, this); return false;\"></span></td>";
		else 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_allow' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 1, this); return false;\"></span></td>";
	}	
	
	if (allowedACL.charAt(2) != "_"){ 
		if(Delete == "_") 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_deny' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 2, this); return false;\"></span></td>";
		else 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_allow' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 2, this); return false;\"></span></td>";
	}	
	
	if (allowedACL.charAt(3) != "_"){ 
		if(Modify == "_") 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_deny' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 3, this); return false;\"></span></td>";
		else 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_allow' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 3, this); return false;\"></span></td>";
	}	
	
	if (allowedACL.charAt(4) != "_"){ 
		if(Execute == "_") 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_deny' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 4, this); return false;\"></span></td>";
		else 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_allow' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 4, this); return false;\"></span></td>";
	}
	
	if (allowedACL.charAt(5) != "_"){ 
		if(View == "_") 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_deny' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 5, this); return false;\"></span></td>";
		else 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_allow' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 5, this); return false;\"></span></td>";
	}
	
	if (allowedACL.charAt(6) != "_"){ 		
		if(Read == "_") 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_deny' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 6, this); return false;\"></span></td>";
		else 
			sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\"><span class='auth_allow' style='cursor: pointer;' onclick=\"coviACL_isAllowedACL('" + target + "', 6, this); return false;\"></span></td>";
	}
	
	sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
	
	if (pIsSubInclude == "Y" && pStrObjectType_A.toUpperCase() != "UR") {
		sHTML +=    "<span class='auth_allow' style='cursor: pointer;' onclick=\"coviACL_isSubInclude('" + target + "', this); return false;\"></span>";
	} else if (pIsSubInclude == "N" && pStrObjectType_A.toUpperCase() != "UR") {
		sHTML +=    "<span class='auth_deny' style='cursor: pointer;' onclick=\"coviACL_isSubInclude('" + target + "', this); return false;\"></span>";
	}
	
    sHTML +=    "</td>";
    sHTML +=    "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
    if (pIsInherited) {
    	sHTML +=    "	<input type='button' value='" + CFN_GetDicInfo(g_aclVariables.dictionary.del, g_aclVariables.lang) + "' class='AXButtonSmall' onclick=\"coviACL_delRow('" + target + "', this);return false;\" style='display: none;'>";
    } else {
    	sHTML +=    "	<input type='button' value='" + CFN_GetDicInfo(g_aclVariables.dictionary.del, g_aclVariables.lang) + "' class='AXButtonSmall' onclick=\"coviACL_delRow('" + target + "', this);return false;\">";
    }
    sHTML +=    "</td>";
    sHTML += "</tr>";
    
    return sHTML;
}

function coviACL_delRow(target, el) {
	var $tr = $(el).parent().parent();
	
	// 상속 받고 있는 권한을 삭제 시도
	if($tr.find("span").hasClass("inherited_label")) {
		parent.Common.Warning(CFN_GetDicInfo(g_aclVariables.dictionary.msg_inheritedDel, g_aclVariables.lang), "Warning Dialog", function () { });   // 상속 받고 있는 권한은 삭제할 수 없습니다. 상위 권한 상속을 해제 하여 주십시요.
		return;
	} else {
		Common.Confirm(CFN_GetDicInfo(g_aclVariables.dictionary.msg_checkDel, g_aclVariables.lang), 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
	        if (result) {
	        	var subjCode = $tr.attr("objectcode");
	        	coviACL_setDelInfo($tr);
	            $tr.remove();
	        	
	            //데이터 삭제
	            coviACL_deleteACLBySubject(target, subjCode);
	            
	            //radio 초기화
	            $('#' + target + '_hTblAcl input[type=radio]').removeAttr('checked');
	        }
	    });
	}
}

function coviACL_clickSubject(target, el) {
	var $this = $(el);
	var subjCode = $this.attr("objectcode");
	
	$('.aclSubject').css("background-color", "inherit");
	$('.aclSubject').removeAttr("data-clicked");
	
	$this.css("background-color", "#E0FFFF");
	$this.attr("data-clicked", subjCode);
	
	// 권한 전체 허용 체크 박스 초기화
	$("#" + target + "_chkAll").removeAttr('checked');
	
	if ($this.find(".inherited_label").length > 0) {
		// 상속일 경우 권한 선택 라디오버튼 비활성화
		$("#" + target + "_hTblAcl").find("input").prop("disabled", true);
		$("#" + target + "_hTblAcl").find("label").css("opacity", "0.7");
		
		// 상속일 경우 권한 전체 허용 체크박스 비활성화
		$("#" + target + "_chkAll").prop("disabled", true);
		$("#" + target + "_chkAll").parent().css("opacity", "0.7");
	} else {
		// 상속이 아닌 경우 권한 선택 라디오버튼 활성화
		$("#" + target + "_hTblAcl").find("input").prop("disabled", false);		
		$("#" + target + "_hTblAcl").find("label").css("opacity", "1");
		
		// 상속이 아닌 경우 권한 전체 허용 체크박스 활성화
		$("#" + target + "_chkAll").prop("disabled", false);
		$("#" + target + "_chkAll").parent().css("opacity", "1");
	}
	
	var item = coviACL_getACLBySubject(target, subjCode);
		
	// Radio 영역 set
	var aclList = item.AclList;	
	coviACL_setACLRdo(aclList, 0, 'S', target);
	coviACL_setACLRdo(aclList, 1, 'C', target);
	coviACL_setACLRdo(aclList, 2, 'D', target);
	coviACL_setACLRdo(aclList, 3, 'M', target);
	coviACL_setACLRdo(aclList, 4, 'E', target);
	coviACL_setACLRdo(aclList, 5, 'V', target);
	coviACL_setACLRdo(aclList, 6, 'R', target);
	coviACL_setSubIncludeRdo(item.IsSubInclude, item.SubjectType, "SubInclude", target);
}

function coviACL_getACLBySubject(target, subjCode){
	var ret;
	var data = coviCmn.aclVariables[target];
	$(data).each(function (i, item) {
		if(item.SubjectCode == subjCode){
			ret = item;
			return false;
		}
	});
	
	return ret;
}

function coviACL_updateACLBySubject(target, subjCode, aclList, isSubInclude){
	var data = coviCmn.aclVariables[target];
	
	var modSubjectCode;
	var modSubjectType;
	
	$(data).each(function (i, item) {
		if(item.SubjectCode == subjCode){
			modSubjectCode = item.SubjectCode;
			modSubjectType = item.SubjectType;
			
			item.AclList = aclList;
			item.Security = aclList.charAt(0);
			item.Create = aclList.charAt(1);
			item.Delete = aclList.charAt(2);
			item.Modify = aclList.charAt(3);
			item.Execute = aclList.charAt(4);
			item.View = aclList.charAt(5);
			item.Read = aclList.charAt(6);
			item.IsSubInclude = isSubInclude;
			return false;
		}
	});
	
	// action table insert
	var isExist = false;
	var actionData = coviCmn.aclActionTable[target];
	$(actionData).each(function(i, item) {
		if(item.SubjectCode == subjCode){
			isExist = true;		
			return false;
		}
	});
	
	if(!isExist) {
		var actionObj = {
			SubjectCode : modSubjectCode,
			SubjectType : modSubjectType,
			Action : "MOD"
		}
		
		actionData.push(actionObj);
	}
}

function coviACL_deleteACLBySubject(target, subjCode){
	var data = coviCmn.aclVariables[target];
	
	var delSubjectCode;
	var delSubjectType;
	
	$(data).each(function (i, item) {
		if(item.SubjectCode == subjCode){
			delSubjectCode = item.SubjectCode;
			delSubjectType = item.SubjectType;
			
			data.splice(i, 1);
			return false;
		}
	});
	
	// action table insert
	var actionData = coviCmn.aclActionTable[target];
	var isNew = false;
	$(actionData).each(function(i, item) {
		if(item.SubjectCode == subjCode){
			if(item.Action == "NEW") {
				isNew = true;
			}	
			actionData.splice(i, 1);
			return false;
		}
	});
	
	if(!isNew) {
		var actionObj = {
			SubjectCode : delSubjectCode,
			SubjectType : delSubjectType,
			Action : "DEL"
		}
		
		actionData.push(actionObj);
	}
}

function coviACL_checkAll(obj){
	if ($(obj).prop("checked")){
		$(obj).closest("div").prev().find("td").each(function(i, item) {
			$(item).find("input[type='radio']").eq(0).prop("checked",true);
			$(item).find("input[type='radio']").eq(0).trigger('change');
		});
	}
}

function coviACL_isAllowedACL(target, index, el) {
	var chkStr = "SCDMEVR";
	
	var $tr = $(el).parent().parent();
	
	if ($tr.find(".inherited_label").length > 0) {
		return;
	}
	
	var subjCode = $tr.attr("objectcode");
	var authClass = $(el).attr("class") == "auth_allow" ? "auth_deny" : "auth_allow";
	
	// 현재 권한 정보
	var item = coviACL_getACLBySubject(target, subjCode);	
	var aclList = item.AclList;	
	var aclArray = Array.from(aclList);
	
	// 선택한 권한 변경
	aclArray[index] = aclArray[index] == "_" ? chkStr.charAt(index) : "_";
	coviACL_updateACLBySubject(target, item.SubjectCode, aclArray.join(""), item.IsSubInclude);
	
	$(el).attr("class", authClass);
}

//하위부서 선택 여부
function coviACL_isSubInclude(target, el) {
	var $tr = $(el).parent().parent();
	
	if ($tr.find(".inherited_label").length > 0) {
		return;
	}
	
	var subjCode = $tr.attr("objectcode");
	var isSubInclude = $(el).attr("class") == "auth_allow" ? "N" : "Y";
	var authClass = $(el).attr("class") == "auth_allow" ? "auth_deny" : "auth_allow";
	
	// 현재 권한 정보
	var item = coviACL_getACLBySubject(target, subjCode);
	coviACL_updateACLBySubject(target, item.SubjectCode, item.AclList, isSubInclude);
	
	$(el).attr("class", authClass);
}

function setAuthSetting(item) {
	var AclList = item[0].hasOwnProperty("AclList") ? item[0].AclList : coviACL.config.initialACL;
	var IsSubInclude = item[0].hasOwnProperty("IsSubInclude") ? item[0].IsSubInclude : coviACL.config.initSubInclude;
	var sCode = item[0].AN;
	var sObjectType_A = "";
	var inherited = "N";
	
	$('.aclSubject').each(function () {
		if($(this).attr("objectcode") == sCode) {
			sObjectType_A = $(this).attr("objecttype_a");
			inherited = $(this).find(".inherited_label").length > 0 ? "Y" : "N";
		}
	});

	coviACL_setACLRdo(AclList, 0, 'S', coviACL.config.target);
    coviACL_setACLRdo(AclList, 1, 'C', coviACL.config.target);
    coviACL_setACLRdo(AclList, 2, 'D', coviACL.config.target);
    coviACL_setACLRdo(AclList, 3, 'M', coviACL.config.target);
    coviACL_setACLRdo(AclList, 4, 'E', coviACL.config.target);
    coviACL_setACLRdo(AclList, 5, 'V', coviACL.config.target);
    coviACL_setACLRdo(AclList, 6, 'R', coviACL.config.target);	
    coviACL_setSubIncludeRdo(IsSubInclude, sObjectType_A, "SubInclude", coviACL.config.target);
    
    if (inherited == "Y") {
		// 상속일 경우 권한 선택 라디오버튼 비활성화
		$("#" + coviACL.config.target + "_hTblAcl").find("input").prop("disabled", true);
		$("#" + coviACL.config.target + "_hTblAcl").find("label").css("opacity", "0.7");
		
		// 상속일 경우 권한 전체 허용 체크박스 비활성화
		$("#" + coviACL.config.target + "_chkAll").prop("disabled", true);
		$("#" + coviACL.config.target + "_chkAll").parent().css("opacity", "0.7");
	} else {
		// 상속이 아닌 경우 권한 선택 라디오버튼 활성화
		$("#" + coviACL.config.target + "_hTblAcl").find("input").prop("disabled", false);
		$("#" + coviACL.config.target + "_hTblAcl").find("label").css("opacity", "1");
		
		// 상속이 아닌 경우 권한 전체 허용 체크박스 활성화
		$("#" + coviACL.config.target + "_chkAll").prop("disabled", false);
		$("#" + coviACL.config.target + "_chkAll").parent().css("opacity", "1");	
	}
}