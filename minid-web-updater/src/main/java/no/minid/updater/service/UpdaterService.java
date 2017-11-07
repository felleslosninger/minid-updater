package no.minid.updater.service;

import no.difi.kontaktinfo.dto.UserUpdateMessage;

public interface UpdaterService {

    void processUpdateMessage(UserUpdateMessage updatedUserData);

}
