package egovframework.covision.groupware.board.user.service;

import egovframework.baseframework.data.CoviMap;


public interface MessageFavoriteSvc {
	int selectFavoriteGridCount(CoviMap params) throws Exception;
	CoviMap selectFavoriteGridList(CoviMap params) throws Exception;
	
	int createFavorite(CoviMap params)throws Exception;		
	int deleteFavorite(CoviMap params)throws Exception;
}
