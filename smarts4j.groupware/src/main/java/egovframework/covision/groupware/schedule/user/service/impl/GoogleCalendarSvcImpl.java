package egovframework.covision.groupware.schedule.user.service.impl;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;




import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import com.google.api.client.auth.oauth2.AuthorizationCodeRequestUrl;
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.auth.oauth2.TokenResponse;
import com.google.api.client.auth.oauth2.TokenResponseException;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.auth.oauth2.GoogleRefreshTokenRequest;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.client.util.DateTime;
import com.google.api.services.calendar.Calendar;
import com.google.api.services.calendar.CalendarScopes;
import com.google.api.services.calendar.model.Event;
import com.google.api.services.calendar.model.Event.Creator;
import com.google.api.services.calendar.model.Event.Reminders;
import com.google.api.services.calendar.model.EventAttachment;
import com.google.api.services.calendar.model.EventAttendee;
import com.google.api.services.calendar.model.EventDateTime;
import com.google.api.services.calendar.model.EventReminder;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.covision.groupware.schedule.user.service.GoogleCalendarSvc;


@Service("googleCalendarService")
public class GoogleCalendarSvcImpl extends EgovAbstractServiceImpl implements GoogleCalendarSvc{
	private Logger LOGGER = LogManager.getLogger(GoogleCalendarSvcImpl.class);

	private static final JsonFactory JSON_FACTORY =JacksonFactory.getDefaultInstance();
//	private static HttpTransport HTTP_TRANSPORT;
	private static final java.util.List<String> SCOPES =Arrays.asList(CalendarScopes.CALENDAR);
	static com.google.api.services.calendar.Calendar service = null;
	static Credential credential = null;
	static String clientId = "750404077527-05f2ksi7qs6k9u812sh61puoevj3s0ju.apps.googleusercontent.com";
	static String clientSecret = "t9IXmCsPC9FGCxcDbRr7GZp3";
	static String refreshToken = "1/5kK_IMCoIyDncLZdTxU8bPnX--HuZH9DlX1E5oLghDKPCzsDSxtOpKkirC7-81YE";


	//구글 계정에 인증하여 토큰을 받는 함수
	@Override
	public void googleOauth() throws Exception{
		//System.out.println("oauth");
		HttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();

		//flow객체를 사용하여 인증정보를 획득할 수 있는 객체를 생성한다.
		GoogleAuthorizationCodeFlow flow =
				new GoogleAuthorizationCodeFlow.Builder(HTTP_TRANSPORT, JSON_FACTORY, clientId, clientSecret, SCOPES)
				.setAccessType("offline")
				.build();

		LocalServerReceiver receiver = new LocalServerReceiver();

		try {
			String redirectUri = receiver.getRedirectUri();
			AuthorizationCodeRequestUrl authorizationUrl = flow.newAuthorizationUrl();
			authorizationUrl.setRedirectUri(redirectUri);
			String url = authorizationUrl.build();
			Runtime.getRuntime().exec(new String[]{"C:/Program Files (x86)/Google/Chrome/Application/chrome.exe", url});
			String code = receiver.waitForCode();  //인증코드를 기다린다.

			TokenResponse response1 = flow.newTokenRequest(code).setRedirectUri(redirectUri).execute(); //처음 토큰을 얻을 때

			//System.out.println("code : "+code);

			//refresh token의 만료
			//1. 사용자가 엑세스 취소
			//2. 6개월 동안 미사용
			//3. 토큰 발급 횟수가 50회 이상인 경우
			//4. 구글 메일과 연동되었을 경우 사용자가 비밀번호를 바꾸었을 경우
			//System.out.println(response1.getRefreshToken()); //이 refresh token을 데이터 베이스에 저장!

			//System.out.println(response1.getAccessToken()); 
			SessionHelper.setSession("RefreshToken", response1.getRefreshToken());
			SessionHelper.setSession("AccessToken", response1.getAccessToken());
			//System.out.println("토큰 생성 성공");

		} catch (TokenResponseException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (FileNotFoundException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}

	//RefreshToken을 사용하여  AccessToken을 받아오는 함수
	public String refreshAccessToken(String refreshToken, HttpTransport HTTP_TRANSPORT) throws Exception {

		String result = null;
		try {
			TokenResponse response =
					new GoogleRefreshTokenRequest(HTTP_TRANSPORT, new JacksonFactory(),
							refreshToken, clientId, clientSecret).execute();
			//System.out.println("Access token: " + response.getAccessToken());
			result= response.getAccessToken();
			return result;
		} catch (TokenResponseException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return result;
	}
	@Override
	//구글 이벤트를 출력하는 함수
	public CoviList googleListAll() throws Exception{
		String accessToken = SessionHelper.getSession("accessToken");
		//System.out.println("refresh : "+SessionHelper.getSession("RefreshToken"));
		//System.out.println("accessToken : "+SessionHelper.getSession("AccessToken"));
		HttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();

		if(SessionHelper.getSession("AccessToken")==null){
			SessionHelper.setSession("AccessToken", refreshAccessToken(refreshToken, HTTP_TRANSPORT));
			//System.out.println("session updated");
		}

		CoviMap jObject = new CoviMap();
		CoviList jArray = new CoviList();//배열이 필요할때

		Credential credential = new GoogleCredential.Builder()
				.setClientSecrets(clientId, clientSecret)
				.setTransport(HTTP_TRANSPORT).build()
				.setAccessToken(accessToken);

		Calendar service = new Calendar.Builder(HTTP_TRANSPORT, JSON_FACTORY, credential).setApplicationName("calendar").build();
		com.google.api.services.calendar.model.Events events = null;
		try {

			DateTime now = new DateTime(System.currentTimeMillis());
			events = service.events().list("primary")
					//orderby - startTime, updated
					.setOrderBy("startTime") //
					//반복 이벤트를 인스턴스로 확장하여 단일 일회성 이벤트 및 반복 이벤트의 인스턴스 만 반환하지만 기본 반복 이벤트 자체는 반환하지 않습니다. 선택 과목. 기본값은 False입니다
					//true : 반복이벤트를 전체 출력
					//false : 반복이벤트 중 시작하는 이벤트만 출력/ 단일이벤트가 하나만 있을 경우 출력안됨/ 하나의 이벤트만 수정했을 경우 다른 이벤트와, 나머지 이벤트의 시작이벤트만 출력한다.
					.setSingleEvents(true) //false일 경우 데이터가 출력되지 않습니다.

					.execute();
			//반복이벤트가 있을 수 있어 최대 10개만 출력될 수 있게
		} catch (IOException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		if (events != null) {
			java.util.List<Event> items = events.getItems();
			//System.out.println("***events***");
			if (items.size() != 0) {
				for (Event event : items) {
					//사용가능한 이벤트 api 
					//https://developers.google.com/resources/api-libraries/documentation/calendar/v3/java/latest/com/google/api/services/calendar/model/Event.html

					DateTime start = event.getStart().getDateTime();
					DateTime end = event.getEnd().getDateTime();
					String summary = event.getSummary();
					String eventId = event.getId();
					List<EventAttachment> attachment= event.getAttachments();

					String colorId = event.getColorId();

					List<EventAttendee> attendee = event.getAttendees();
					Reminders reminders = event.getReminders();
					DateTime create = event.getCreated();
					Creator creator = event.getCreator();
					String htmllink = event.getHtmlLink();
					String location = event.getLocation();
					DateTime updated = event.getUpdated();
					List<String> rrule = event.getRecurrence();
					if (start == null && end==null) {
						start = event.getStart().getDate();
						end = event.getEnd().getDate();
					}

					jObject.put("start", start);
					jObject.put("end", end);
					jObject.put("eventId", eventId);
					jObject.put("summary", summary);
					jObject.put("attachment", attachment);
					jObject.put("colorId", colorId);
					jObject.put("attendee", attendee);
					jObject.put("reminders", reminders);
					jObject.put("create", create);
					jObject.put("creator", creator);
					jObject.put("htmllink", htmllink);
					jObject.put("location", location);
					jObject.put("updated", updated);

					jArray.add(jObject);

					//System.out.println("시작시간 : "+start);
					//System.out.println("끝 시간 : "+end);
					//System.out.println("이벤트 id : "+eventId);
					//System.out.println("제목 : "+summary);
					//System.out.println("첨부파일 : "+attachment);
					//System.out.println("color id : "+colorId);
					//System.out.println("참석자 : "+attendee);
					//System.out.println("알림 : "+reminders);
					//System.out.println("생성시간 : "+create);
				}
			}
		}
		return jArray;
	}
	@Override
	//단일 이벤트를 출력하는 함수
	public void googleListSingle(){

	}
	//    @SuppressWarnings("deprecation")
	@Override
	public void googleAdd(CoviMap dataObj)throws Exception{
		String accessToken = SessionHelper.getSession("accessToken");
		HttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
		//String access_token = refreshAccessToken(refreshToken);

		if(SessionHelper.getSession("AccessToken")==null){
			SessionHelper.setSession("AccessToken", refreshAccessToken(refreshToken, HTTP_TRANSPORT));
			//System.out.println("session updated");
		}

		Credential credential = new GoogleCredential.Builder()
				.setClientSecrets(clientId, clientSecret)
				.setJsonFactory(JSON_FACTORY).setTransport(HTTP_TRANSPORT).build()
				.setRefreshToken(refreshToken)
				.setAccessToken(accessToken);
		//System.out.println("refresh : "+SessionHelper.getSession("RefreshToken"));
		//System.out.println("refresh : "+SessionHelper.getSession("AccessToken"));
		Calendar service = new Calendar.Builder(HTTP_TRANSPORT, JSON_FACTORY, credential).build();

		String summary = dataObj.getString("summary");
		String description = dataObj.getString("description");

		String startTime = dataObj.getString("startTime");
		startTime+=":00+09:00";
		String startTimeZone = dataObj.getString("startTimeZone");
		String endTime = dataObj.getString("endTime");
		endTime+=":00+09:00";
		String endTimeZone = dataObj.getString("endTimeZone");


		String method = dataObj.getString("method");
		String location = dataObj.getString("location");
		String attendee = dataObj.getString("attendee");
		String rrule = dataObj.getString("rrule");
		int minute = Integer.parseInt(dataObj.getString("minute"));

		Event event = new Event()
				.setSummary(summary)
				.setLocation(location)
				.setDescription(description);
		try{
			//		Date date=new Date(2017-1900, 8-1, 30);
			//		DateTime start_time_test = new DateTime(date);
			//		DateTime end_time_test = new DateTime(date);
			//구글에서 '종일' 옵션을 선택하면 시간을 설정하지 않고 입력하는 방법
			//아래의 .setDateTime(start_time_test)을 해주면 된다.

			DateTime startDateTime = new DateTime(startTime);
			EventDateTime start = new EventDateTime()
					.setDateTime(startDateTime)
					.setTimeZone(startTimeZone);
			event.setStart(start);	

			DateTime endDateTime = new DateTime(endTime);
			EventDateTime end = new EventDateTime()
					.setDateTime(endDateTime)
					.setTimeZone(endTimeZone);
			event.setEnd(end);

			//event.setOriginalStartTime(originalStartTime) 하루 종일 이벤트를 하고 싶은 경우 사용한다.

			if(rrule !=null && !rrule.equals("")){
				String[] recurrence = new String[] {rrule};
				event.setRecurrence(Arrays.asList(recurrence));
			}
			//RRULE:FREQ반복일정의 반복일 (daily : 매일 | weekly : 매주 - 추가로 요일도 설정 | 

			if(attendee != null && !attendee.equals("@gmail.com")){
				EventAttendee[] attendees = new EventAttendee[] {
						new EventAttendee().setEmail(attendee)
				};
				event.setAttendees(Arrays.asList(attendees));
			}
			//		System.out.println("startDate : "+startTime);
			//    	System.out.println("endDate : "+endTime);

			EventReminder[] reminderOverrides = new EventReminder[] {
					new EventReminder().setMethod(method).setMinutes(minute)
			};
			Event.Reminders reminders = new Event.Reminders()
					.setUseDefault(false)
					.setOverrides(Arrays.asList(reminderOverrides));
			event.setReminders(reminders);

			EventAttachment[] eventattachment = new EventAttachment[]{
					new EventAttachment().setFileUrl("aaa").setTitle("aaa")
			};

			event.setAttachments(Arrays.asList(eventattachment));

			String calendarId = "primary";
			event = service.events().insert(calendarId, event).execute();
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		//System.out.printf("Event created: %s\n", event.getHtmlLink());
	}
	@Override
	public void googleDelete(CoviMap dataObj) throws Exception{
		String accessToken = SessionHelper.getSession("accessToken");
		String eventId = dataObj.getString("eventId");	    

		HttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
		//String access_token = refreshAccessToken(refreshToken);


		Credential credential = new GoogleCredential.Builder()
				.setClientSecrets(clientId, clientSecret)
				.setJsonFactory(JSON_FACTORY).setTransport(HTTP_TRANSPORT).build()
				.setRefreshToken(refreshToken)
				.setAccessToken(accessToken);

		Calendar service = new Calendar.Builder(HTTP_TRANSPORT, JSON_FACTORY, credential).build();

		service.events().delete("primary", eventId).execute();

	}

	@Override
	public void googleUpdate(CoviMap dataObj) throws Exception {
		String accessToken = SessionHelper.getSession("accessToken");
		//update
		HttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
		//String access_token = refreshAccessToken(refreshToken);
		//System.out.println("access Token : "+SessionHelper.getSession("AccessToken"));
		if(SessionHelper.getSession("AccessToken")==null){
			SessionHelper.setSession("AccessToken", refreshAccessToken(refreshToken, HTTP_TRANSPORT));
			//System.out.println("session updated");
		}
		Credential credential = new GoogleCredential.Builder()
				.setClientSecrets(clientId, clientSecret)
				.setJsonFactory(JSON_FACTORY).setTransport(HTTP_TRANSPORT).build()
				.setRefreshToken(refreshToken)
				.setAccessToken(accessToken);

		Calendar service = new Calendar.Builder(HTTP_TRANSPORT, JSON_FACTORY, credential).build();


		//String access_token = refreshAccessToken(refreshToken);
		String summary = dataObj.getString("summary");
		String description = dataObj.getString("description");
		String startTime = dataObj.getString("startTime");
		if(startTime!=null && !startTime.equals(""))
			startTime+=":00+09:00";
		String startTimeZone = dataObj.getString("startTimeZone");
		String endTime = dataObj.getString("endTime");
		if(endTime!=null && !endTime.equals(""))
			endTime+=":00+09:00";
		String endTimeZone = dataObj.getString("endTimeZone");
		String method = dataObj.getString("method");
		String location = dataObj.getString("location");
		String attendee = dataObj.getString("attendee");
		String rrule = dataObj.getString("rrule");
		String eventId = dataObj.getString("eventId");
		int minute = Integer.parseInt(dataObj.getString("minute"));

		//System.out.println("eventid : "+eventId);
		Event event = service.events().get("primary", eventId).execute();

		//System.out.println("event : "+event.getSummary());
		//System.out.println("event_time : "+event.getStart());

		if(summary!=null && !summary.equals(""))
			event.setSummary(summary);
		if(location!=null && !location.equals(""))
			event.setLocation(location);
		if(description!=null && !description.equals(""))
			event.setDescription(description);

		try{
			if(startTime!=null && startTimeZone!=null && !startTime.equals("") && !startTimeZone.equals("")){
				DateTime startDateTime = new DateTime(startTime);
				EventDateTime start = new EventDateTime()
						.setDateTime(startDateTime)
						.setTimeZone(startTimeZone);
				event.setStart(start);	
			}

			if(endTime!=null && endTimeZone!=null && !endTime.equals("") &&!endTimeZone.equals("")){
				DateTime endDateTime = new DateTime(endTime);
				EventDateTime end = new EventDateTime()
						.setDateTime(endDateTime)
						.setTimeZone(endTimeZone);
				event.setEnd(end);
			}

			//event.setOriginalStartTime(originalStartTime) 하루 종일 이벤트를 하고 싶은 경우 사용한다.
			if(rrule !=null && !rrule.equals("")){
				String[] recurrence = new String[] {rrule};
				event.setRecurrence(Arrays.asList(recurrence));
			}
			//RRULE:FREQ반복일정의 반복일 (daily : 매일 | weekly : 매주 - 추가로 요일도 설정 | 

			if(attendee != null && !attendee.equals("@gmail.com")){
				EventAttendee[] attendees = new EventAttendee[] {
						new EventAttendee().setEmail(attendee)
				};
				event.setAttendees(Arrays.asList(attendees));
			}
			//System.out.println("startDate : "+startTime);
			//System.out.println("endDate : "+endTime);

			if(method!=null && minute!=0){
				EventReminder[] reminderOverrides = new EventReminder[] {
						new EventReminder().setMethod(method).setMinutes(minute)
				};
				Event.Reminders reminders = new Event.Reminders()
						.setUseDefault(false)
						.setOverrides(Arrays.asList(reminderOverrides));
				event.setReminders(reminders);
			}
		} catch(NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		service.events().update("primary", eventId, event).execute();

	}
}
