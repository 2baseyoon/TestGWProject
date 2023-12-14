package egovframework.covision.proxy.synap;

import org.apache.commons.httpclient.NameValuePair;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.FileUtil;

import java.net.URLEncoder;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Controller
public class ProxyController {
	private Logger LOGGER = LogManager.getLogger(ProxyController.class);
	
	String synapServer = null;
	
	@CrossOrigin
	@RequestMapping(value = "/**")
	public void requestSynapDocViewServer(HttpServletRequest request, HttpServletResponse response) throws Exception {
		if(request.getRequestURI().indexOf("common/convertPreview.do") > -1) {
			return;
		}
		request.setCharacterEncoding("UTF-8");
		//LOGGER.error("BaseConfig[MobileDocConverterServer] : " + synapServer);
		if(synapServer == null) {
			LOGGER.info("synapServer is null, BaseConfig[MobileDocConverterServer] : " + synapServer);
		}
		synapServer = RedisDataUtil.getBaseConfig("MobileDocConverterServer");
		synapServer = synapServer.substring(0, synapServer.indexOf("/SynapDocViewServer"));
		
		//String synapServer = "http://192.168.11.22:8084";
		String timeout = "360000";
		RequestSynapDocView.requestSynapDocViewServer(synapServer, timeout, request, response);
	}
	
	
	//사이냅 연결
	@RequestMapping(value = "common/convertPreview.do")
	public void  convertPreview(HttpServletRequest request, HttpServletResponse response) throws Exception {
		// 모듈 다운로드 Path 관련 수정사항이 있을 수 있으므로 coviframework  으로뺌.
		CoviMap result = FileUtil.makeSynapDownParamenter(request);
		
		String fileID = result.getString("fileID");
		String WaterMarkText = result.getString("WaterMarkText");
		String filePath = result.getString("filePath");
			
		try{
			NameValuePair[] data = {
				    new NameValuePair("fid", "filePreview"+fileID),
				    new NameValuePair("fileType", "URL"),
				    
				    new NameValuePair("convertType", "1"),
				    new NameValuePair("filePath",filePath),
				    new NameValuePair("watermarkText",WaterMarkText),
				    //new NameValuePair("sync", "false"), // 결과정보만 받을경우
				    new NameValuePair("sync", "true"), // Viewer redirect
				    new NameValuePair("force", "false")
		    };
			
			StringBuilder queryString = new StringBuilder();
			for(NameValuePair nvp: data) {
				if(queryString.length() > 0) {
					queryString.append("&");	
				}
				queryString.append(nvp.getName() + "=" + URLEncoder.encode(nvp.getValue(),"UTF-8"));
			}
			request.getRequestDispatcher("/job?" + queryString).forward(request, response);
		}catch(NullPointerException e){
			LOGGER.error("convertPreview", e);
		 }catch(Exception e){
	    	  LOGGER.error("convertPreview", e);
		 }
	}
}

