package com.nexora.pattern.observer;

import java.util.ArrayList;
import java.util.List;

/** ConcreteSubject: Delivery status එක වෙනස් වුණාම observers ට දැනුම් දෙනවා */
public class DeliveryStatusSubject implements Subject {

    private final List<Observer> observers = new ArrayList<>();
    private String message;

    @Override
    public void addObserver(Observer o) { observers.add(o); }

    @Override
    public void removeObserver(Observer o) { observers.remove(o); }

    @Override
    public void notifyObservers() {
        for (Observer o : observers) {
            o.update(message);
        }
    }

    public void statusChanged(int deliveryId, String newStatus, int staffId) {
        this.message = "DELIVERY: Delivery #" + deliveryId + " is now '" + newStatus
                + "' (updated by staff ID " + staffId + ")";
        notifyObservers();
    }
}
