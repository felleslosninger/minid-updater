package no.minid.updater.jms;

import javax.jms.Message;
import javax.jms.TextMessage;

import no.difi.kontaktinfo.dto.UserUpdateMessage;
import no.minid.updater.service.UpdaterService;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * MessageListener that receives messages from JMS queue.
 * Handles MinID user update messages from Kontaktinfo backend.
 * @author Kons-fbo
 *
 */
public class UserUpdateMessageListener implements javax.jms.MessageListener {

	private static final Logger LOG = Logger.getLogger(UserUpdateMessageListener.class);
	
	private static final ObjectMapper mapper = new ObjectMapper();
	
	@Autowired
	UpdaterService updaterService;
	
	public UserUpdateMessageListener() {
	    super();
	}
	
	/**
	 * Handles message from queue.  Processes text messages with user update entries in JSON format
	 * See {@link UserUpdateMessage}.
	 * 
	 * @param msg {@link UserUpdateMessage} in JSON format.
	 * @throws RuntimeException if MinID connection fails.
	 */
	public void onMessage(final Message msg) {
	    LOG.info("Got message: " + msg);
	    UserUpdateMessage userUpdate = null;
		
	    if (msg instanceof TextMessage) {
		    try {
		        String msgAsText = ((TextMessage) msg).getText();
                userUpdate = mapper.readValue(msgAsText, UserUpdateMessage.class);
            } catch (Exception e) {
                LOG.error("Got exception when parsing JMS message. Message is discarded. --- " + msg, e);
                return;
            }
		    
		    try {
		        updaterService.processUpdateMessage(userUpdate);
		    }catch(RuntimeException rEx) {
		        LOG.error("MinID user update failed for data: " + userUpdate, rEx);
		        throw rEx;
		    }
		} else {
		    LOG.error("Unhandled message type: " + msg.getClass().getName() + "Message: " + msg.toString() + ". Message is discarded.");		    
		}
	}
}
