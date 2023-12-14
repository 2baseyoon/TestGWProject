package egovframework.api.admin.service.impl;

import javax.annotation.Resource;

import org.apache.commons.net.util.SubnetUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.api.admin.service.AuthorizationSvc;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.RedisShardsUtil;

@Service
public class AuthorizationSvcImpl extends EgovAbstractServiceImpl implements AuthorizationSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	private static final String KEY = "API_CACHE_IPLIST";
//	public static final String CHANNELID = "API_IPSECURE_EVT";
//	
//	private RedisLettuceSentinelUtil lettuceUtil;
//	private APIIPSecureRedisPubSubListener listener;
	
//	@PostConstruct
//	@Override
//	public void init () {
//		RedisShardsUtil instance = RedisShardsUtil.getInstance();
//		if(instance instanceof RedisLettuceSentinelUtil && listener == null) {
//			lettuceUtil = (RedisLettuceSentinelUtil)instance;
//			listener = new APIIPSecureRedisPubSubListener();
//			lettuceUtil.subscribe(AuthorizationSvcImpl.CHANNELID, listener);
//			
//			// LOGGER.info("AuthorizationSvcImpl IP Config cache change listen started.");
//		}
//	}
	
	/**
	 * 허용 IP체크
	 */
	@Override
	public void checkRequestIP(String requestIP) throws Exception {
		boolean isAllowed = false;
		if("0:0:0:0:0:0:0:1".equals(requestIP) || "127.0.0.1".equals(requestIP) || "localhost".equals(requestIP)) {
			return;
		}
		CoviMap ipList = getIPSecureList();
		
//		String ipListStr = RedisShardsUtil.getInstance().get(KEY);
//		ipList = new CoviMap(ipListStr);
		CoviList rejectList = ipList.getJSONArray("reject");
		CoviList allowList = ipList.getJSONArray("allow");
		
		CoviMap info = null;
		// 차단IP인 경우 바로 Exception 처리.
		for(int i = 0; rejectList != null && i < rejectList.size(); i++) {
			info  = rejectList.getJSONObject(i);
			String ipMaskStr = info.getString("IP");
			if(isContainsIP(ipMaskStr, requestIP)) {
				throw new Exception("Restricted IP. ["+requestIP+"]");
			}
		}
		
		// 차단IP가 아닌경우 허용IP인지 체크
		for(int i = 0; allowList != null && i < allowList.size(); i++) {
			info  = allowList.getJSONObject(i);
			String ipMaskStr = info.getString("IP");
			if(isContainsIP(ipMaskStr, requestIP)) {
				isAllowed = true;
				break;
			}
		}
		
		if(!isAllowed) {
			throw new Exception("Restricted IP. ["+requestIP+"]");
		}
	}
	
	@Override
	public void reloadIPSecureList() throws Exception {
		CoviMap saveInfo = getIPSecureList();
		RedisShardsUtil.getInstance().save(KEY, saveInfo.toJSONString());
		// Redis 에 캐시시에 subscribe Event 로 api 서버에서 메모리 갱신.
	}
	
	
	private CoviMap getIPSecureList() throws Exception {
		CoviList ipList = selectIPSecureList(null);
		CoviMap info = null;
		
		CoviMap saveInfo = new CoviMap();
		CoviList rejectList = new CoviList();
		CoviList allowList = new CoviList();
		for(int i = 0; ipList != null && i < ipList.size(); i++) {
			info  = ipList.getJSONObject(i);
			String controlType = info.getString("ControlType");
			if("REJECT".equals(controlType)) {
				rejectList.add(info);
			}else if("ACCEPT".equals(controlType)) {
				allowList.add(info);
			}
		}
		saveInfo.put("reject", rejectList);
		saveInfo.put("allow", allowList);
		
		return saveInfo;
	}
	
	private boolean isContainsIP(String ipMaskStr, String requestIP) {
		// mask 포함하여 IP에 포함되는지 확인후 return. ex) 192.168.11.0/24
		if(ipMaskStr != null && ipMaskStr.indexOf("/") == 0-1) {
			ipMaskStr = ipMaskStr + "/32";
		}
		SubnetUtils utils = new SubnetUtils(ipMaskStr);
		utils.setInclusiveHostCount(true);
		return utils.getInfo().isInRange(requestIP);
	}

	private CoviList selectIPSecureList(CoviMap params) throws Exception {
		return coviMapperOne.list("api.admin.config.selectIPSecureListForCache", params);
	}
}
