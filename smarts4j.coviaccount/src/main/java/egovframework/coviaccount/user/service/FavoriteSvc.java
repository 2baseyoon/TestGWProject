package egovframework.coviaccount.user.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;



public interface FavoriteSvc {
	
	public CoviMap getList(CoviMap params);
	
	public void register(CoviList jsonArray);
}
