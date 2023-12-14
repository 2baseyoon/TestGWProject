package egovframework.coviaccount.user.service.impl;

import java.util.HashMap;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.OpinetSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("OpinetSvc")
public class OpinetSvcImpl extends EgovAbstractServiceImpl implements OpinetSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	// code - F220523161
	private static String code = RedisDataUtil.getBaseConfig("eAccOpinetCode");
	// url - http://www.opinet.co.kr/api/avgRecentPrice.do
	private static String url = RedisDataUtil.getBaseConfig("eAccOpinetURL");

	@Override
	public CoviMap getList(CoviMap params) throws Exception {
		
		CoviMap jsonObject = new CoviMap();
		
		int cnt	= 0;
		int pageNo = Integer.parseInt(params.get("pageNo").toString());
		int pageSize = Integer.parseInt(params.get("pageSize").toString());
		int pageOffset = (pageNo - 1) * pageSize;

		params.put("pageNo", pageNo);
		params.put("pageSize", pageSize);
		params.put("pageOffset", pageOffset);
		
		cnt = (int) coviMapperOne.getNumber("account.opinet.getListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("account.opinet.getList", params);
		
		jsonObject.put("list", AccountUtil.convertNullToSpace(list));
		jsonObject.put("page", page);
		
		return jsonObject;
	}

	@Override
	public void getSync() throws Exception {
		
		RestTemplate restTemplate = new RestTemplate();
		
		// prodcd - B034: 고급휘발유, B027: 보통휘발유, D047: 자동차경유, C004: 실내등유, K015: 자동차부탄
		UriComponents builder = UriComponentsBuilder.fromHttpUrl(url)
				.queryParam("out", "json")
				.queryParam("code", code)
				.build();
		
		JsonNode jsonNode = new ObjectMapper()
			.readTree(restTemplate.getForObject(builder.toUri(), String.class))
			.get("RESULT")
			.get("OIL");
		
		for (int i = 0; i < jsonNode.size(); i++) {
			CoviMap params = new CoviMap();
			params.put("YYYYMMDD", jsonNode.get(i).get("DATE").asText());
			params.put("PRICE", jsonNode.get(i).get("PRICE").asText());
			params.put("PRODCD", jsonNode.get(i).get("PRODCD").asText());
			params.put("REGISTERID", SessionHelper.getSession("UR_Code"));
			params.put("MODIFIERID", SessionHelper.getSession("UR_Code"));
			
			int cnt = (int) coviMapperOne.getNumber("account.opinet.registerCnt", params);
			if(cnt == 0) {
				coviMapperOne.insert("account.opinet.register", params);
			}
		}
	}

	@Override
	public CoviMap getOpinet(CoviMap params) throws Exception {
		CoviMap jsonObject = new CoviMap();
		
		jsonObject.put("opinet", coviMapperOne.selectOne("account.opinet.getOpinet", params));
		
		return jsonObject;
	}
}
