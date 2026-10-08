package com.nexora.util;

import java.util.regex.Pattern;


public class ValidationUtil {

    private static final Pattern NAME = Pattern.compile("^\\p{L}[\\p{L} .'-]{2,49}$");
    private static final Pattern EMAIL = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]{2,}$");
    private static final Pattern PHONE = Pattern.compile("^(?:0[1-9]\\d{8}|\\+94[1-9]\\d{8})$");


    public static String validateRegistration(String fullName, String email, String password,
                                              String phone, String address) {
        if (fullName == null || !NAME.matcher(fullName.trim()).matches()) {
            return "Name must be 3-50 letters (no numbers or symbols).";
        }
        if (email == null || email.trim().length() > 100 || !EMAIL.matcher(email.trim()).matches()) {
            return "Enter a valid email address.";
        }
        if (password == null || password.length() < 6 || password.length() > 50
                || !password.matches(".*[A-Za-z].*") || !password.matches(".*\\d.*")) {
            return "Password must be 6-50 characters with at least one letter and one number.";
        }
        if (phone != null && !phone.trim().isEmpty()
                && !PHONE.matcher(phone.replaceAll("\\s+", "")).matches()) {
            return "Use a Sri Lankan phone number like 0771234567 or +94771234567.";
        }
        if (address != null && address.trim().length() > 200) {
            return "Address must be 200 characters or less.";
        }
        return null;
    }
}