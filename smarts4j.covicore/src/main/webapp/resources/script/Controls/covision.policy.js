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
*
*	CHECK: 그리드 체크 항목 가져오는거, Ajax request 날리는 항목 공통으로 뺄 수 있을 것 같다.
*
*
*/
$.fn.serializeObject = function() {
    var obj = null;
    try {
        if ( this[0].tagName && this[0].tagName.toUpperCase() == "FORM" ) {
            var arr = this.serializeArray();
            if ( arr ) {
                obj = {};
                jQuery.each(arr, function() {
                    obj[this.name] = this.value;
                });             
            }//if ( arr ) {
        }
    }
    catch(e) {alert(e.message);}
    
    return obj;
};

var regexPWLevel1 = /^.*(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d].*$/;
var regexPWLevel2 = /^.*(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=*]).*$/;
var regexPWLevel3 = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&+=*])[A-Za-z\d!@#$%^&+=*].*$/;
var regexPWContinuous = /(.)\1{2,}/;

var pwPolicy = {
		dictionary : {
			msg_ChangePasswordDSCR14 : '최소 {0}자 이상/영문 문자, 숫자 각각 1개 이상 조합하여 사용하여야 합니다.;At least {0} characters must be used in combination with at least one letter or number.;{0}文字以上/英語文字、数字、それぞれ1つ以上組み合わせて使用​​すべきです。;至少{0}个字符必须与至少一个字母或数字组合使用。;;;;;;',
			msg_ChangePasswordDSCR13 : '최소 {0}자 이상/영문 문자, 숫자, 특수문자 각각 1개 이상 조합하여 사용하여야 합니다.;At least {0} characters must be used in combination with at least one letter, number, and special character.;{0}文字以上/英語文字、数字、特殊文字それぞれ1個以上組み合わせて使用​​すべきです。;至少{0}个字符必须与至少一个字母，数字和特殊字符组合使用。;;;;;',
			msg_ChangePasswordDSCR12 : '최소 {0}자 이상/영문 대소문자, 숫자, 특수문자 각각 1개 이상 조합하여 사용하여야 합니다.;At least {0} characters must be used in combination with at least one of upper and lower case letters, numbers and special characters.;{0}文字以上/英語大文字と小文字、数字、特殊文字それぞれ1個以上組み合わせて使用​​すべきです。;至少{0}个字符必须与大写和小写字母，数字和特殊字符中的至少一个结合使用。;;;;;',
			msg_ChangePasswordDSCR11 : '최소 {0}자 이상으로 조합하여 사용하여야 합니다.;At least {0} characters must be used in combination.;{0}文字以上で組み合わせて使用​​すべきです。;至少{0}个字符必须组合使用。;;;;;',
			msg_ChangePasswordDSCR10 : '동일문자를 연속 3개 이상 사용할 수 없습니다.;You can not use more than 3 consecutive characters.;同じ文字を連続して3つ以上の使用できません;您不能使用超过3个连续的字符。;;;;;',
		},
		//패스워드가 설정된 레벨과 맞는지.
		isPwLevel : function( id, level, len ){
			if(level == "1"){
				if (!regexPWLevel1.test($("#"+id ).val() )) {
					Common.Warning(CFN_GetDicInfo(pwPolicy.dictionary.msg_ChangePasswordDSCR14).replace("{0}", len), "" , function(){
						$("#"+id ).focus();
					});
					return false;
				}else{
					return true;
				}
			}else if(level == "2"){
				if (!regexPWLevel2.test($("#"+id ).val() )) {
					Common.Warning(CFN_GetDicInfo(pwPolicy.dictionary.msg_ChangePasswordDSCR13).replace("{0}", len), "" , function(){
						$("#"+id ).focus();
					});
					return false;
				}else{
					return true;
				}	
			}else if(level == "3"){
				if (!regexPWLevel3.test($("#"+id ).val() )) {
					Common.Warning(CFN_GetDicInfo(pwPolicy.dictionary.msg_ChangePasswordDSCR12).replace("{0}", len), "" , function(){
						$("#"+id ).focus();
					});
					return false;
				}else{
					return true;
				}	
			}else{
				if ($("#"+id ).val().length < len) {
					Common.Warning(CFN_GetDicInfo(pwPolicy.dictionary.msg_ChangePasswordDSCR11).replace("{0}", len), "" , function(){
						$("#"+id ).focus();
					});
					return false;
				}else{
					return true;
				} 
			}
			 
		},
		
		isPwContinuous : function( id){
			if (regexPWContinuous.test($("#"+id ).val())) {
				Common.Warning(CFN_GetDicInfo(pwPolicy.dictionary.msg_ChangePasswordDSCR10), "" , function(){
					$("#"+id ).focus();
				});
				return false;
			}else{
				return true;
			} 
			
		}
	
}

