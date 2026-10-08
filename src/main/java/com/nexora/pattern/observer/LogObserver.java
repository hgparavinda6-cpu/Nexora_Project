package com.nexora.pattern.observer;

import java.time.LocalDateTime;

/** ConcreteObserver: server console එකට log කරනවා */
public class LogObserver implements Observer {

    @Override
    public void update(String message) {
        System.out.println("[" + LocalDateTime.now() + "] " + message);
    }
}
