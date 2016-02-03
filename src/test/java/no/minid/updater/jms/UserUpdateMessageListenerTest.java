package no.minid.updater.jms;

import com.fasterxml.jackson.databind.ObjectMapper;
import no.difi.kontaktinfo.dto.UserUpdateMessage;
import no.minid.updater.exception.LdapSystemException;
import no.minid.updater.service.UpdaterService;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.ObjectMessage;
import javax.jms.TextMessage;
import java.io.StringWriter;
import java.util.Date;

import static org.mockito.Mockito.*;


public class UserUpdateMessageListenerTest {

    @InjectMocks
    UserUpdateMessageListener listener = new UserUpdateMessageListener();

    @Mock
    TextMessage message;

    @Mock
    UpdaterService updaterService;

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testOnMessageOk() throws Exception {
        final UserUpdateMessage userUpdateMessage = new UserUpdateMessage("ssn", "email", "mobile", new Date(), UserUpdateMessage.UpdateStatusCode.MODIFIED);
        when(message.getText()).thenReturn(toJson(userUpdateMessage));

        listener.onMessage(message);
        verify(updaterService).processUpdateMessage(eq(userUpdateMessage));
    }

    @Test(expected = RuntimeException.class)
    public void testOnMessageRuntimeException() throws Exception {
        final UserUpdateMessage userUpdateMessage = new UserUpdateMessage("ssn", "email", "mobile", new Date(),
                        UserUpdateMessage.UpdateStatusCode.MODIFIED);

        when(message.getText()).thenReturn(toJson(userUpdateMessage));
        doThrow(new LdapSystemException("Error", null)).when(updaterService).processUpdateMessage(userUpdateMessage);

        listener.onMessage(message);
        verify(updaterService).processUpdateMessage(eq(userUpdateMessage));
    }

    @Test
    public void testUnhandledMessageType() {
        Message msg = mock(ObjectMessage.class);
 
        listener.onMessage(msg);
        verify(updaterService, never()).processUpdateMessage(isA(UserUpdateMessage.class));
    }

    @Test
    public void testJsonUnmarshallFails() throws JMSException {
        when(message.getText()).thenReturn("Invalid JSON string");
        
        listener.onMessage(message);
        // Json parser exception will not throw exception. Service should not be called.
        verify(updaterService, never()).processUpdateMessage(isA(UserUpdateMessage.class));
    }

    private String toJson(UserUpdateMessage msg) throws Exception {
        StringWriter writer = new StringWriter();
        ObjectMapper mapper = new ObjectMapper();
        mapper.writeValue(writer, msg);
        return writer.toString();
    }

}
