package com.nexora.pattern.observer;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;


public class AdminAlertObserver implements Observer {

    private static final List<String> ALERTS = new CopyOnWriteArrayList<>();

    @Override
    public void update(String message) {
        ALERTS.add(message);
        if (ALERTS.size() > 20) {
            ALERTS.remove(0);
        }
    }

    public static List<String> getAlerts() { return ALERTS; }

    public static void clear() { ALERTS.clear(); }
}