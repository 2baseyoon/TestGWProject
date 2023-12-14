package egovframework.covision.groupware.base;

import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@ServerEndpoint("/ws")
public class WsServer {
	private Logger LOGGER = LogManager.getLogger(WsServer.class);
	
	private static Set<Session> clients = Collections.synchronizedSet(new HashSet<Session>());
	
	@OnOpen
	public void onOpen(Session session){
		//System.out.println("Open Connection ...");
		clients.add(session);
	}
	
	@OnClose
	public void onClose(Session session){
		//System.out.println("Close Connection ...");
		clients.remove(session);
	}
	
	@OnMessage
	public void onMessage(Session session, String message) throws IOException{
		
		/*System.out.println("Message from the client: " + message);
		String echoMsg = "Echo from the server : " + message;
		return echoMsg;*/
		sendMessage(message);
	}
	
	public static void sendMessage(String message) throws IOException{
		synchronized (clients) {
			// Iterate over the connected sessions
			// and broadcast the received message
			for (Session client : clients) {
				//if (!client.equals(session)) {
					client.getBasicRemote().sendText(message);
				//}
			}
		}
	}
	
	@OnError
	public void onError(Throwable e){
		LOGGER.error(e.getLocalizedMessage(), e);
	}
}
