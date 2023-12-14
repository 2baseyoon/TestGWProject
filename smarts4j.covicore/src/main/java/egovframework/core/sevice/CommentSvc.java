package egovframework.core.sevice;


import egovframework.baseframework.data.CoviMap;

public interface CommentSvc {
	public CoviMap select(CoviMap params) throws Exception;
	public CoviMap selectOne(CoviMap params) throws Exception;
	public int selectCommentCount(CoviMap params) throws Exception;
	public int selectReplyCount(int memberOf) throws Exception;
	public int selectLikeCount(CoviMap params) throws Exception;
	public CoviMap insert(CoviMap params)throws Exception;
	public int insertLike(CoviMap params)throws Exception;
	public CoviMap update(CoviMap params) throws Exception;
	public CoviMap delete(CoviMap params) throws Exception;
	public int selectMyLike(CoviMap params)throws Exception;
	public CoviMap updateComment(CoviMap params)throws Exception;
	public CoviMap selectSenderCode(CoviMap params)throws Exception;
	
	//mobile
	public CoviMap selectListAll(CoviMap params) throws Exception;
}
