package egovframework.core.sevice;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface MenuSvc {
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
	public int moveMenu(CoviMap params)throws Exception;
	public int exportMenu(CoviMap params)throws Exception;
	public void removeRedisMenuCache(String pDomainID)throws Exception;
	public Long selectChildCount(CoviMap params) throws Exception;
}
