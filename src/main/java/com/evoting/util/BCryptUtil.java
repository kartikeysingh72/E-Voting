package com.evoting.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * BCrypt password hashing utility.
 * Uses cost factor of 12 for strong hashing.
 */
public class BCryptUtil {

    private static final int LOG_ROUNDS = 12;

    /**
     * Hash a plain text password using BCrypt.
     */
    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(LOG_ROUNDS));
    }

    /**
     * Verify a plain text password against a BCrypt hash.
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
