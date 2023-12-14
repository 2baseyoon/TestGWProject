package egovframework.coviframework.batch;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

/**
 * @Class Name  : ApplicationContextUtils.java
 * @Description : 스프링이 init 될시에  initiatingBean과 ApplicationContextAware 인터페이스를 구현한 클래스 찾아 빈으로 등록함으로,하나의 컨트롤러에서 자신이 사용하는 컨텍스트 이외에, 다른 컨텍스트를 이용하는 경우 사용하는 class
 * 				  bean들의 id값을 가지고 applicationcontext객체로 부터 동적으로 객체를 얻을 때 사용
 * @Modification 
 * << 개정이력(Modification Information) >>
 * 
 *  수정일                   수정자                  수정내용
 *  ---------   ---------   -------------------------------
 *  2016.1.16   이성문                   최초작성
 *
 * @author 이성문
 * @since 2016. 1. 16.
 * @version 1.0
 * @see
 */

public class CoviApplicationContextUtils implements ApplicationContextAware {

	private static ApplicationContext ctx;

	/**
	 * ApplicationContext setter
	 * @param appContext ApplicationContext
	 * @exception BeansException
	 * @return 
	 */
	@Override
	public void setApplicationContext(ApplicationContext appContext) {
		ctx = appContext;
	}

	/**
	 * ApplicationContext getter
	 * @param 
	 * @exception 
	 * @return 
	 */
	public static ApplicationContext getApplicationContext() {
		return ctx;
	}
}