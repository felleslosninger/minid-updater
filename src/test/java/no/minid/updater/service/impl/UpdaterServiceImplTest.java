package no.minid.updater.service.impl;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.*;

import java.util.Date;

import no.difi.kontaktinfo.dto.UserUpdateMessage;
import no.difi.kontaktinfo.dto.UserUpdateMessage.UpdateStatusCode;
import no.idporten.domain.user.MinidUser;
import no.idporten.domain.user.PersonNumber;
import no.minid.exception.MinidUserNotFoundException;
import no.minid.ldap.dao.MinidDao;
import no.minid.service.MinIDService;
import no.minid.updater.exception.LdapSystemException;

import org.apache.commons.lang.time.DateUtils;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class UpdaterServiceImplTest {
    
    @Mock
    MinIDService minIDService;
    
    @InjectMocks
    UpdaterServiceImpl service = new UpdaterServiceImpl();
    
    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
    }
    
    @Test
    public void testProcessUpdateMessageWithNewDate() throws MinidUserNotFoundException {
    	PersonNumber personNumber = new PersonNumber("02014047797");
        MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(new Date());
        contact.setPersonNumber(personNumber);
        final UserUpdateMessage msg = new UserUpdateMessage(personNumber.toString(), "email@email.no", "90090900", DateUtils.addHours(contact.getProfileUpdatedDate(), 1), UpdateStatusCode.MODIFIED);
        when(minIDService.findByPersonNumber(personNumber)).thenReturn(contact);
        service.processUpdateMessage(msg);
        verify(minIDService).updateContactInformation(contact);
        assertEquals(msg.getEmail(), contact.getEmail().toString());
        assertEquals(msg.getMobile(), contact.getPhoneNumber().toString());
        assertEquals(msg.getLastModified(), contact.getProfileUpdatedDate());
    }
    
    @Test
    public void testProcessUpdateMessageWithNullLdapDate() throws MinidUserNotFoundException {
        PersonNumber personNumber = new PersonNumber("02014047797");
        MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(null);
        contact.setPersonNumber(personNumber);
        final UserUpdateMessage msg = new UserUpdateMessage(personNumber.toString(), "email@email.no", "90090900", new Date(), UpdateStatusCode.MODIFIED);
        when(minIDService.findByPersonNumber(personNumber)).thenReturn(contact);
        service.processUpdateMessage(msg);
        verify(minIDService).updateContactInformation(contact);
        assertEquals(msg.getEmail(), contact.getEmail().toString());
        assertEquals(msg.getMobile(), contact.getPhoneNumber().toString());
        assertEquals(msg.getLastModified(), contact.getProfileUpdatedDate());
    }
    
    @Test(expected=LdapSystemException.class)
    public void testProcessUpdateMessageWithReadException() throws MinidUserNotFoundException {
        final UserUpdateMessage msg = new UserUpdateMessage("02014047797", "email@email.no", "90090900", new Date(), UpdateStatusCode.MODIFIED);
        when(minIDService.findByPersonNumber(new PersonNumber(msg.getSsn()))).thenThrow(new RuntimeException("junit test exception"));
        service.processUpdateMessage(msg);
        verify(minIDService, never()).updateContactInformation(isA(MinidUser.class));
    }
    
    @Test
    public void testProcessUpdateMessageWithUserNotFound() throws MinidUserNotFoundException  {
        final UserUpdateMessage msg = new UserUpdateMessage("02014047797", "email@email.no", "90090900", new Date(), UpdateStatusCode.MODIFIED);
        when(minIDService.findByPersonNumber(new PersonNumber(msg.getSsn()))).thenReturn(null);
        service.processUpdateMessage(msg);
        verify(minIDService, never()).updateContactInformation(isA(MinidUser.class));
    }
    
    @Test
    public void testUpdateContactInfoWithOldModifiedDate() throws MinidUserNotFoundException {
        MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(new Date());
        contact.setPersonNumber(new PersonNumber("02014047797"));
        final UserUpdateMessage msg = new UserUpdateMessage("02014047797", "email@email.no", "90090900", DateUtils.addHours(contact.getProfileUpdatedDate(), -1), UpdateStatusCode.MODIFIED);
        service.updateContactInfo(msg, contact);
        verify(minIDService, never()).updateContactInformation(isA(MinidUser.class));
    }
    
    @Test
    public void testUpdateContactInfoWithEqualModifiedDate() throws MinidUserNotFoundException {
    	MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(new Date());
        contact.setPersonNumber(new PersonNumber("02014047797"));
        final UserUpdateMessage msg = new UserUpdateMessage("02014047797", "email@email.no", "90090900", new Date(contact.getProfileUpdatedDate().getTime()), UpdateStatusCode.MODIFIED);
        service.updateContactInfo(msg, contact);
        verify(minIDService, never()).updateContactInformation(isA(MinidUser.class));
    }
    
    @Test(expected=LdapSystemException.class)
    public void testUpdateContactInfoWithLdapException() throws MinidUserNotFoundException {
    	MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(new Date());
        
        doThrow(new RuntimeException("Junit test feil")).when(minIDService).updateContactInformation(contact);
        
        final UserUpdateMessage msg = new UserUpdateMessage("02014047797", "email@email.no", "90090900", DateUtils.addHours(contact.getProfileUpdatedDate(), 1), UpdateStatusCode.MODIFIED);
        service.updateContactInfo(msg, contact);        
    }    

}
