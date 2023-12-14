package egovframework.coviframework.filter;

import java.io.File;
import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;

/**
 * WAS 동적압축이 아닌 미리 압축(GZIP) 된 js 파일에 대해 header 를 변조하여 Browser 가 해석/압축해제 할 수 있도록 하는 필터
 * 기준 : 요청한 js 파일명 + .gzorg 파일이 존재할 경우 요청한 js 파일은 gzip 압축된 것으로 간주함.
 * 파일 수정 - 부득이 하게 파일이 변경되어야 할 경우 
 * 		1) 원본파일(.gzorg) 파일 내용을 참고후 수정하여 다시 gzip 압축하여 **.js 로 위치시켜 놓는다. 
 * 		2) ***.js 파일을 일반 js 파일로 교체한 후 .gzorg 파일을 삭제한다. (해당파일은 plain 제공됨)
 *  	3) 원본파일(.gzorg) 참고하여 수정한후 .gzorg 확장자로 저장만 해놓고 압축프로그램을 돌린다.
 *  
 * 해당 Filter 에서는 혹시라도 동적으로 압축하는 등의 로직을 추가하지 말것.(for Performance) 
 * 
 * @since 2023/10/19
 * @author hgsong@RD02
 */
public class GZIPHeaderFilter implements Filter {

	@SuppressWarnings("unused")
	private FilterConfig config;
	
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		this.config = filterConfig;
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		if(response instanceof HttpServletResponse) {
			HttpServletRequest req = (HttpServletRequest)request;
			
			String requestURI = req.getRequestURI();
			if(requestURI != null && requestURI.endsWith("js")) {
				// origin : /covicore/resources/xxx
				requestURI = requestURI.replaceFirst(req.getContextPath(), "");// /resources/xxx 
				
				String filePath = req.getSession().getServletContext().getRealPath(requestURI);
				filePath = StringUtils.replace(filePath, "\\", "/");
				
				File f = new java.io.File(filePath);
				if(f.exists()) {
					if(new File(f.getParent(), f.getName() + ".gzorg").exists()) {
						HttpServletResponse res = (HttpServletResponse)response;
						if(res.containsHeader("Content-Encoding")) {
							res.setHeader("Content-Encoding", "gzip");
						}else {
							res.addHeader("Content-Encoding", "gzip");
						}
						
						if(res.containsHeader("Content-Type")) {
							res.setHeader("Content-Type", "application/x-gzip");
						}else {
							res.addHeader("Content-Type", "application/x-gzip");
						}
					}
				}
			}
		}
		
		chain.doFilter(request, response);
	}

	@Override
	public void destroy() {
	}

}
