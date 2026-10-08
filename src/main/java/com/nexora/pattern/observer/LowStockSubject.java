package com.nexora.pattern.observer;

import java.util.ArrayList;
import java.util.List;


public class LowStockSubject implements Subject {

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


    public void setMessage(String message) {
        this.message = message;
        notifyObservers();
    }


    public void checkStock(String productName, int stockQty, int lowLevel) {
        if (stockQty <= lowLevel) {
            setMessage("LOW STOCK: " + productName + " has only " + stockQty
                    + " left (alert level " + lowLevel + ")");
        }
    }
}