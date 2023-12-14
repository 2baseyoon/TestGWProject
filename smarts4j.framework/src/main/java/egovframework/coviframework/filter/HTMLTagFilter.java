package egovframework.coviframework.filter;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

/**
 * 전자정부 프레임웍의 egovframework.rte.ptl.mvc.filter.HTMLTagFilter 버젼이 변경(4.0) 되면서 사이드이펙트 발생
 * 3.9 버젼과 동일하게 자체 Filter 처리하며, 이후 필요시 여기를 수정. 
 * @author hgsong
 */
public class HTMLTagFilter implements Filter {

	@SuppressWarnings("unused")
	private FilterConfig config;
	
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		this.config = filterConfig;
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		chain.doFilter(new HTMLTagFilterRequestWrapper((HttpServletRequest) request), response);
	}

	@Override
	public void destroy() {
	}

}
