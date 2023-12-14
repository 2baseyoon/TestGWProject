package egovframework.covision.coviflow.govdocs.util;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestTemplate;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;


/**
 * AsyncTaskEdmsTransfer *
 */
@Service("asyncTaskOpenDocSender")
public class AsyncTaskOpenDocSender{
	
	private Logger LOGGER = LogManager.getLogger(AsyncTaskOpenDocSender.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	/**
	 * 본문 컨버젼
	 * 상태값 : SENDERROR
	 */
	@Transactional
	@Async("executorOpenDocSend")
	public void executeOpenDocSend(final CoviMap spParams) throws Exception{
		CoviMap param = new CoviMap();
		String targetDate = spParams.getString("targetDate");
		try {
			LinkedMultiValueMap<String, String> params = new LinkedMultiValueMap<String, String>();
			params.add("targetDate", targetDate);
			CoviMap 	returnObj 	= new CoviMap();
			RestTemplate restTemplate = new RestTemplate();
			returnObj = (CoviMap) restTemplate.postForObject(PropertiesUtil.getGlobalProperties().getProperty("govDoc.path")+"govdocs/service/sendCSVManual.do", params, CoviMap.class);	    	
			if( returnObj.get("status").equals("FAIL") ) throw new Exception();
			
//			param.put("STATE", ApprovalGovDocSvc.OPENDOC_STATE_SENDCOMPLETE);
//			coviMapperOne.update("user.govDoc.openDoc.updateStatSatus", param);
		}catch(NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			param.put("targetDate", targetDate);//Error
			param.put("RST", "FAIL");
			coviMapperOne.update("user.govDoc.openDoc.updateStatSatus", param);
		}catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			param.put("targetDate", targetDate);//Error
			param.put("RST", "FAIL");
			coviMapperOne.update("user.govDoc.openDoc.updateStatSatus", param);
		}
	}

}