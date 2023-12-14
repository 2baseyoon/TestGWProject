package egovframework.coviframework.base;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.support.WebBindingInitializer;
import org.springframework.web.context.request.WebRequest;

/**  
 * @Class Name   : CommonBindingInitializer.java
 * @Description  : 여러 컨트롤러에 PropertyEditor 적용
 * @Modification : Information  
 */
public class CommonBindingInitializer implements WebBindingInitializer {
	/**
	 * initBinder
	 * @param binder WebDataBinder HTTP 요청정보를 컨트롤러 메소드의 파라미터나 모델에 바인딩할 때 사용되는 바인딩 오브젝트
	 * @param request WebRequest URI (Uniform Resource Identifier)로 요청 리퀘스트 오브젝트
	 */
	@Override
	public void initBinder(WebDataBinder binder, WebRequest request) {
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		dateFormat.setLenient(false);
		binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, false));
		binder.registerCustomEditor(String.class, new StringTrimmerEditor(false));
	}

	@Override
	public void initBinder(WebDataBinder binder) {
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		dateFormat.setLenient(false);
		binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, false));
		binder.registerCustomEditor(String.class, new StringTrimmerEditor(false));
	}


}