package no.minid.updater.service;

import no.difi.kontaktinfo.dto.UserUpdateMessage;

public interface UpdaterService {
	
	public void processUpdateMessage(UserUpdateMessage updatedUserData);

}
