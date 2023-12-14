package egovframework.core.manage.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface MenuManageSvc {
	public CoviMap select(CoviMap params) throws Exception;
	public CoviMap selectTree(CoviMap params) throws Exception;
	public CoviMap selectMoveTargetForValidation(CoviMap params) throws Exception;
	public CoviMap insert(CoviMap paramMenu, CoviList aclInfo)throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public CoviMap selectAuth(CoviMap params) throws Exception;
	public CoviMap update(CoviMap params, CoviList aclInfo)throws Exception;
	public Object updateIsUse(CoviMap params)throws Exception;
	public int delete(CoviMap params)throws Exception;
	public int move(CoviMap params)throws Exception;
	public Long selectChildCount(CoviMap menuId) throws Exception ;
	public Long selectMaxSortKey(CoviMap menuId) throws Exception ;
	public int moveMenu(CoviMap params)throws Exception;
	public int exportMenu(CoviMap params)throws Exception;
	public void removeRedisMenuCache(String pDomainID)throws Exception;
}
