package com.nexora.pattern.observer;

/** Servlet එකෙන් call කරන්නේ මේක. Subject එක හදලා observers දෙක register කරනවා. */
public class DeliveryTracker {

    private static final DeliveryStatusSubject SUBJECT = new DeliveryStatusSubject();

    static {
        SUBJECT.addObserver(new LogObserver());                    // කලින් හදපු එකම observer එක
        SUBJECT.addObserver(new DeliveryNotificationObserver());   // අලුත් observer එක
    }

    public static void statusChanged(int deliveryId, String newStatus, int staffId) {
        SUBJECT.statusChanged(deliveryId, newStatus, staffId);
    }
}