package com.nexora.pattern.observer;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/** ConcreteObserver: delivery updates ගබඩා කරනවා (පස්සේ page එකක පෙන්නන්න පුළුවන්) */
public class DeliveryNotificationObserver implements Observer {

    private static final List<String> NOTES = new CopyOnWriteArrayList<>();
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    @Override
    public void update(String message) {
        NOTES.add(LocalDateTime.now().format(FMT) + "  " + message);
        if (NOTES.size() > 20) {
            NOTES.remove(0);   // අන්තිම 20ක් විතරක්
        }
    }

    public static List<String> getNotifications() { return NOTES; }
}