package com.evoting.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Properties;

/**
 * Email utility for sending OTP emails via JavaMail API.
 */
public class EmailUtil {

    private static String SMTP_HOST;
    private static String SMTP_PORT;
    private static String USERNAME;
    private static String PASSWORD;
    private static String FROM_NAME;

    static {
        try {
            Properties appProps = new Properties();
            InputStream is = EmailUtil.class.getClassLoader().getResourceAsStream("app.properties");
            if (is != null) {
                appProps.load(is);
                SMTP_HOST = appProps.getProperty("mail.smtp.host", "smtp.gmail.com");
                SMTP_PORT = appProps.getProperty("mail.smtp.port", "587");
                USERNAME = appProps.getProperty("mail.username");
                PASSWORD = appProps.getProperty("mail.password");
                FROM_NAME = appProps.getProperty("mail.from.name", "E-Voting Platform");
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to load email configuration", e);
        }
    }

    /**
     * Send an email with the given subject and HTML body.
     */
    public static boolean sendEmail(String toEmail, String subject, String htmlBody) {
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=utf-8");
            Transport.send(message);
            return true;
        } catch (MessagingException | UnsupportedEncodingException e) {
            System.err.println("Failed to send email to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Send OTP email with formatted HTML.
     */
    public static boolean sendOTPEmail(String toEmail, String otpCode, String purpose) {
        String subject = "E-Voting Platform - Your OTP Code";
        String htmlBody = """
            <!DOCTYPE html>
            <html>
            <head><style>
                body { font-family: Arial, sans-serif; background: #f4f4f4; padding: 20px; }
                .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 8px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                .otp-code { font-size: 36px; font-weight: bold; color: #2563eb; letter-spacing: 8px; text-align: center; padding: 20px; background: #eff6ff; border-radius: 8px; margin: 20px 0; }
                .footer { color: #666; font-size: 12px; text-align: center; margin-top: 20px; }
            </style></head>
            <body>
                <div class="container">
                    <h2 style="color: #1e40af; text-align: center;">🗳️ E-Voting Platform</h2>
                    <p>Your One-Time Password (OTP) for <strong>%s</strong> is:</p>
                    <div class="otp-code">%s</div>
                    <p>This OTP is valid for <strong>10 minutes</strong>. Do not share it with anyone.</p>
                    <p class="footer">If you did not request this OTP, please ignore this email.<br>
                    &copy; E-Voting Platform - Secure Digital Democracy</p>
                </div>
            </body>
            </html>
            """.formatted(purpose, otpCode);

        return sendEmail(toEmail, subject, htmlBody);
    }
}
