package egovframework.coviaccount.user.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.FavoriteSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("FavoriteSvc")
public class FavoriteSvcImpl extends EgovAbstractServiceImpl implements FavoriteSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getList(CoviMap params) {
		CoviMap jsonObject = new CoviMap();
		
		int cnt	= 0;
		int pageNo = Integer.parseInt(params.get("pageNo").toString());
		int pageSize = Integer.parseInt(params.get("pageSize").toString());
		int pageOffset = (pageNo - 1) * pageSize;

		params.put("pageNo", pageNo);
		params.put("pageSize", pageSize);
		params.put("pageOffset", pageOffset);
		
		cnt = (int) coviMapperOne.getNumber("account.favorite.getListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("account.favorite.getList", params);
		
		jsonObject.put("list", AccountUtil.convertNullToSpace(list));
		jsonObject.put("page", page);
		
		return jsonObject;
	}

	@Override
	public void register(CoviList jsonArray) {
		for(int i = 0; i < jsonArray.size(); i++) {
			CoviMap jsonObject = (CoviMap) jsonArray.get(i);
			
			int cnt = (int)(long) coviMapperOne.selectOne("account.favorite.registerCnt", jsonObject);
			if(cnt == 0) {
				coviMapperOne.insert("account.favorite.register", jsonObject);
			}
		}
	}
	
}
