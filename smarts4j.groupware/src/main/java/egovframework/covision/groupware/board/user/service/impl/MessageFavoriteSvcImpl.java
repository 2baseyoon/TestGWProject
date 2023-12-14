package egovframework.covision.groupware.board.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.groupware.board.user.service.MessageFavoriteSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("MessageFavoriteSvc")
public class MessageFavoriteSvcImpl extends EgovAbstractServiceImpl implements MessageFavoriteSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @param params UserCode
	 * @description 즐겨찾기 게시판(이전 관심게시) 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectFavoriteGridCount(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.board.selectFavoriteGridCount", params);
	}
	
	/**
	 * @param params UserCode
	 * @description 즐겨찾기 게시판(이전 관심게시) 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectFavoriteGridList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("user.board.selectFavoriteGridList",params);
		
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "FolderID,MultiDisplayName,FolderPath,RegistDate"));
		return resultList;
	}
	
	@Override
	public int createFavorite(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.message.createFavorite", params);
	}

	@Override
	public int deleteFavorite(CoviMap params) throws Exception {
		return coviMapperOne.delete("user.message.deleteFavorite", params);
	}
}
