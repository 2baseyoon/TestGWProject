package egovframework.core.sevice;



import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public interface ControlSvc {
	//like
	public int selectLikeCount(CoviMap params) throws Exception;
	public int insertLike(CoviMap params)throws Exception;

	//Subscription
	public int insertSubscription(CoviMap params) throws Exception;
	public int checkDuplicateSubscription(CoviMap params) throws Exception;
	public int deleteSubscription(CoviMap params) throws Exception;
	public int deleteSubscriptionAll(CoviMap params) throws Exception;
	public CoviMap selectSubscriptionList(CoviMap params) throws Exception;
	public CoviMap selectSubscriptionFolderList(CoviMap params) throws Exception;
	
	//Favorite Menu
	public int insertFavoriteMenu(CoviMap params) throws Exception;
	public int checkDuplicateFavoriteMenu(CoviMap params) throws Exception;
	public int deleteFavoriteMenu(CoviMap params) throws Exception;
	public int deleteFavoriteMenuAll(CoviMap params) throws Exception;
	public CoviMap selectFavoriteMenuList(CoviMap params) throws Exception;
	
	//Contact
	public int insertContact(CoviMap params) throws Exception;
	public int deleteContact(CoviMap params) throws Exception;
	public int checkDuplicateContact(CoviMap params) throws Exception;
	public CoviMap selectContactNumberList(CoviMap params) throws Exception;
	public CoviMap selectTodoList(CoviMap params) throws Exception;
	public int insertTodo(CoviMap params) throws Exception;
	public int updateTodo(CoviMap params) throws Exception;
	public void deleteTodo(CoviMap params) throws Exception;
	
	//quick
	public CoviMap selectQuickMenuConf(CoviMap params) throws Exception;
	public void updateUserConf(CoviMap params) throws Exception;
	public CoviList selectIntegratedList(CoviMap params) throws Exception;
	public void updateAlarmIsRead(CoviMap params) throws Exception;
	public void deleteAllAlarm(CoviMap params) throws Exception;
	public void deleteEachAlarm(CoviMap params) throws Exception;
	
	//간편 메일 전송
	public int sendSimpleMail(CoviMap params) throws Exception;
	
	//패스워드 재전송.
	public boolean changePassword(CoviMap paramse)throws Exception;
	public int checkUserCnt(CoviMap paramse)throws Exception;
	public int externalMailCnt(CoviMap paramse)throws Exception;
	public CoviMap recentOTP(CoviMap params) throws Exception;
	public boolean createTwoFactor(CoviMap paramse)throws Exception;
	
	//FIDO
	public int createFido(CoviMap params) throws Exception;
	public String selectFidoStatus(CoviMap params) throws Exception;
	public int updateFidoStatus(CoviMap params) throws Exception;
	public int updateAuthToken(CoviMap params) throws Exception;
	
	// GetObjectInfo - UR, GR, DN
	CoviMap selectObjectOne_UR(CoviMap params) throws Exception;
	CoviMap selectObjectOne_GR(CoviMap params) throws Exception;
	CoviMap selectObjectOne_DN(CoviMap params) throws Exception;
}
