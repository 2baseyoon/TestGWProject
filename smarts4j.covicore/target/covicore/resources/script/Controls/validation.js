
(function($) {
	//정규식     
	var regexEmail = /^[-A-Za-z0-9_]+[-A-Za-z0-9_.]*[@]{1}[-A-Za-z0-9_]+[-A-Za-z0-9_.]*[.]{1}[A-Za-z]{2,5}$/;
	var regexDial=/^[0-9*#]*$/ ;
	
	$.validation = {
		//받은값이 숫자인지 확인
		isNumber : function( value ){
			return $.isNumeric( value ); 
		},
		//받은 아이디 객체의 값이 숫자인지 확인
		isNumberById : function( id ){
			return $.isNumeric( $("#"+id ).val() );
		},
		
	}
	
	var methods ={
			//글자수 제한
			limitChar : function( limit ){
				return this.each(function(event){
					if (this.tagName=='INPUT'){
						$(this).attr("limitChar", "Y");
						$(this).attr("maxlength", limit);
						
					}
				});
			},
			//텍스트박스에 숫자만 입력가능 
			onlyNumber : function() {
				return this.each(function(){
					$(this).css("ime-mode", "disabled" );
					if (this.tagName=='INPUT'){
						$(this).attr("onlyNumber" , "Y");
						$(this).on("keydown", function(event){
							var keyCode = _getKeyCode(event),
							shiftKey = event.shiftKey;
							
							if( !_checkAllowKey(keyCode, shiftKey) && !_checkAllowNumber(keyCode) ){ // 숫자, 기능키가 아닌경우 입력제한
								return false;
							}
						});
						
						$(this).on("keypress", function(event){
							var keyCode = _getKeyCode(event),
							shiftKey = event.shiftKey,
							char =String.fromCharCode(keyCode);

							if( !_checkAllowKey(keyCode, shiftKey) && !$.validation.isNumber(char) ){//숫자가 아닌경우 입력제한
								return false;
							}
						});

					};
				});
			}
	};  
		
	//jquery 엘리먼트에 사용자 정의 함수 추가 (체인사용가능) 
	$.fn.validation = function( method ){
		 if ( methods[method] ) {
		      return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
		    } else if ( typeof method === 'object' || ! method ) {
		      return methods.init.apply( this, arguments );
		    } else {
		      //error
		    }    
	};
	
	//keyCode 가져오기 
	function _getKeyCode( event ){
		var keyCode = "";
		if(window.netscape){
			if( event.which !== 0 ){
				keyCode = event.which; //FF
			}else{
				keyCode = event.keyCode;	
			}
		}else{
			keyCode = event.keyCode;
		}
		return keyCode;
	}
	
	//숫자만
	function _checkAllowNumber( keyCode ){
		if( (keyCode >= 48 &&  keyCode<= 57)  //상단숫자 
			|| (keyCode >= 96 &&  keyCode<= 105) //키패드 숫자
		){
			return true;
		}else{
			return false;
		}
	}
	
	//기능키만
	function _checkAllowKey( keyCode, shiftKey ){
		if(shiftKey === null || shiftKey === undefined ){
			shiftKey = false;//기본값 false
		}
		
		var char = String.fromCharCode(keyCode);
		if( 
			(
			keyCode ===  8 //backspace
			|| keyCode ===  9  //tab
			|| keyCode ===  35 //end
			|| keyCode ===  36 //home
			|| keyCode ===  37 //left arrow
			|| keyCode ===  39 //right arrow
			|| keyCode ===  46 //delete
			
			)
			&& !shiftKey
		){
			return true;
		}else{
			return false;
		}
	}

	 
})(jQuery);



