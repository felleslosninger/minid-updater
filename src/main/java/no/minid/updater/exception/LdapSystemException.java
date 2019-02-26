package no.minid.updater.exception;



/**
 * Exception thrown when LDAP read/update failed.
 * @author Kons-fbo
 *
 */
public class LdapSystemException extends RuntimeException {
        
    private static final long serialVersionUID = -2304802127755162258L;

    public LdapSystemException(String message, Throwable cause) {
        super(message, cause);
    }

    @Override
    public String toString() {
        return "LdapSystemException [message=" + getMessage() + ", cause=" + getCause() + "]";
    }
}
