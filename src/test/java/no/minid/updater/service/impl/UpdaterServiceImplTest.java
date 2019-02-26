package no.minid.updater.service.impl;

import no.difi.kontaktinfo.dto.UserUpdateMessage;
import no.difi.kontaktinfo.dto.UserUpdateMessage.UpdateStatusCode;
import no.idporten.domain.user.MinidUser;
import no.idporten.domain.user.PersonNumber;
import no.minid.exception.MinidUserNotFoundException;
import no.minid.service.MinIDService;
import no.minid.updater.exception.LdapSystemException;
import no.minid.updater.service.impl.UpdaterServiceImpl;
import org.joda.time.DateTime;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Date;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.isA;
import static org.mockito.Mockito.*;

public class UpdaterServiceImplTest {

    private static final String FODSELSNR = "02014047797";
    private static final String EMAIL = "email@email.no";
    private static final String MOBILE = "90090900";

    @Mock
    MinIDService minIDService;

    @InjectMocks
    UpdaterServiceImpl service = new UpdaterServiceImpl(minIDService);

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testProcessUpdateMessageWithNewDate() throws MinidUserNotFoundException {
        PersonNumber personNumber = new PersonNumber(FODSELSNR);
        MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(new Date());
        contact.setPersonNumber(personNumber);
        Date lastModified = new DateTime(contact.getProfileUpdatedDate()).plusHours(1).toDate();
        final UserUpdateMessage msg = new UserUpdateMessage(personNumber.toString(), EMAIL, MOBILE, lastModified, UpdateStatusCode.MODIFIED);
        when(minIDService.findByPersonNumber(personNumber)).thenReturn(contact);
        service.processUpdateMessage(msg);
        verify(minIDService).updateContactInformation(contact);
        assertEquals(msg.getEmail(), contact.getEmail().toString());
        assertEquals(msg.getMobile(), contact.getPhoneNumber().toString());
        assertEquals(msg.getLastModified(), contact.getProfileUpdatedDate());
    }

    @Test
    public void testProcessUpdateMessageWithNullLdapDate() throws MinidUserNotFoundException {

        PersonNumber personNumber = new PersonNumber(FODSELSNR);
        MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(null);
        contact.setPersonNumber(personNumber);
        final UserUpdateMessage msg = new UserUpdateMessage(personNumber.toString(), EMAIL, MOBILE, new Date(), UpdateStatusCode.MODIFIED);
        when(minIDService.findByPersonNumber(personNumber)).thenReturn(contact);
        service.processUpdateMessage(msg);
        verify(minIDService).updateContactInformation(contact);
        assertEquals(msg.getEmail(), contact.getEmail().toString());
        assertEquals(msg.getMobile(), contact.getPhoneNumber().toString());
        assertEquals(msg.getLastModified(), contact.getProfileUpdatedDate());
    }

    @Test(expected= LdapSystemException.class)
    public void testProcessUpdateMessageWithReadException() throws MinidUserNotFoundException {
        final UserUpdateMessage msg = new UserUpdateMessage(FODSELSNR, EMAIL, MOBILE, new Date(), UpdateStatusCode.MODIFIED);
        when(minIDService.findByPersonNumber(new PersonNumber(msg.getSsn()))).thenThrow(new RuntimeException("junit test exception"));
        service.processUpdateMessage(msg);
        verify(minIDService, never()).updateContactInformation(isA(MinidUser.class));
    }

    @Test
    public void testProcessUpdateMessageWithUserNotFound() throws MinidUserNotFoundException {
        final UserUpdateMessage msg = new UserUpdateMessage(FODSELSNR, EMAIL, MOBILE, new Date(), UpdateStatusCode.MODIFIED);
        when(minIDService.findByPersonNumber(new PersonNumber(msg.getSsn()))).thenReturn(null);
        service.processUpdateMessage(msg);
        verify(minIDService, never()).updateContactInformation(isA(MinidUser.class));
    }

    @Test
    public void testUpdateContactInfoWithOldModifiedDate() throws MinidUserNotFoundException {
        MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(new Date());
        contact.setPersonNumber(new PersonNumber(FODSELSNR));
        Date lastModified = new DateTime(contact.getProfileUpdatedDate()).minusHours(1).toDate();
        final UserUpdateMessage msg = new UserUpdateMessage(FODSELSNR,
                EMAIL,
                MOBILE,
                lastModified,
                UpdateStatusCode.MODIFIED);
        service.updateContactInfo(msg, contact);
        verify(minIDService, never()).updateContactInformation(isA(MinidUser.class));
    }

    @Test
    public void testUpdateContactInfoWithEqualModifiedDate() throws MinidUserNotFoundException {
        MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(new Date());
        contact.setPersonNumber(new PersonNumber(FODSELSNR));
        Date lastModified = new Date(contact.getProfileUpdatedDate().getTime());
        final UserUpdateMessage msg = new UserUpdateMessage(FODSELSNR, EMAIL, MOBILE, lastModified, UpdateStatusCode.MODIFIED);
        service.updateContactInfo(msg, contact);
        verify(minIDService, never()).updateContactInformation(isA(MinidUser.class));
    }

    @Test(expected=LdapSystemException.class)
    public void testUpdateContactInfoWithLdapException() throws MinidUserNotFoundException {
        MinidUser contact = new MinidUser();
        contact.setProfileUpdatedDate(new Date());

        doThrow(new RuntimeException("Junit test feil")).when(minIDService).updateContactInformation(contact);

        Date lastModified = new DateTime(contact.getProfileUpdatedDate()).plusHours(1).toDate();
        final UserUpdateMessage msg = new UserUpdateMessage(FODSELSNR, EMAIL, MOBILE, lastModified, UpdateStatusCode.MODIFIED);
        service.updateContactInfo(msg, contact);
    }

}
