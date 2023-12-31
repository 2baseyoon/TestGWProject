package egovframework.covision.groupware.base;

import java.net.URI;

import javax.websocket.ClientEndpoint;
import javax.websocket.CloseReason;
import javax.websocket.ContainerProvider;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.WebSocketContainer;

@ClientEndpoint
public class WsClient {

	public WsClient(URI endpointURI) {
		try {
			WebSocketContainer container = ContainerProvider.getWebSocketContainer();
			container.connectToServer(this, endpointURI);
		} catch (NullPointerException e) {
			throw new NullPointerException();
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private Session userSession = null;

	@OnOpen
	public void onOpen(Session userSession) {
		//System.out.println("client: opening websocket ");
		this.userSession = userSession;
	}

	/**
	 * Callback hook for Connection close events.
	 *
	 * @param userSession the userSession which is getting closed.
	 * @param reason the reason for connection close
	 */
	@OnClose
	public void onClose(Session userSession, CloseReason reason) {
		//System.out.println("client: closing websocket");
		this.userSession = null;
	}

	/**
	 * Callback hook for Message Events. This method will be invoked when a
	 * client send a message.
	 *
	 * @param message The text message
	 */
	@OnMessage
	public void onMessage(String message) {
		//System.out.println("client: received message " + message);
	}

	public void sendMessage(String message) {
		this.userSession.getAsyncRemote().sendText(message);
	}

}
