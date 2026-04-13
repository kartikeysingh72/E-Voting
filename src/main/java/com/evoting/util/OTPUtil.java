package com.evoting.util;

import java.security.SecureRandom;

/**
 * OTP generation utility using SecureRandom for cryptographic safety.
 */
public class OTPUtil {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int OTP_LENGTH = 6;

    /**
     * Generate a 6-digit numeric OTP.
     */
    public static String generateOTP() {
        int otp = 100000 + RANDOM.nextInt(900000);
        return String.valueOf(otp);
    }

    /**
     * Generate a unique receipt token for vote audit trail.
     * Format: ELECTION_ID-VOTER_ID-TIMESTAMP-RANDOM_HEX
     */
    public static String generateReceiptToken(int electionId, int voterId) {
        byte[] bytes = new byte[16];
        RANDOM.nextBytes(bytes);
        StringBuilder hex = new StringBuilder();
        for (byte b : bytes) {
            hex.append(String.format("%02x", b));
        }
        return String.format("EV-%d-%s", electionId, hex.toString().substring(0, 24).toUpperCase());
    }
}
