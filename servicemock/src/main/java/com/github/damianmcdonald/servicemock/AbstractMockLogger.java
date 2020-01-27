package com.github.damianmcdonald.servicemock;

import com.github.javafaker.Faker;

import java.io.FileNotFoundException;
import java.net.MalformedURLException;
import java.net.SocketTimeoutException;
import java.nio.file.AccessDeniedException;
import java.util.Random;

public class AbstractMockLogger {

    private static final int MIN_RANGE = 0;
    private static final int MAX_RANGE = 4;
    private static final String NARRATIVE_EXCEPTION_REQUEST_TIMEOUT = "Request timeout to external payment system with transaction id: %s";
    private static final String NARRATIVE_EXCEPTION_ILLEGAL_ARGUMENT = "External payment failed with id: %s";
    private static final String NARRATIVE_EXCEPTION_FILE_NOT_FOUND = "Missing XML file on external payment system for id: %s";
    private static final String NARRATIVE_EXCEPTION_ACCESS_DENIED = "Access denied on external payment system for id: %s";
    private static final String NARRATIVE_EXCEPTION_MALFORMED_URL = "External payment system endpoint not available for id: %s";
    private final Faker faker = new Faker();

    protected Exception generateException() {
        return getExceptions()[getRandomIntFromRange()];
    }

    private Exception[] getExceptions() {
        return new Exception[]{
                new SocketTimeoutException(String.format(NARRATIVE_EXCEPTION_REQUEST_TIMEOUT, generateIdNumber())),
                new IllegalArgumentException(String.format(NARRATIVE_EXCEPTION_ILLEGAL_ARGUMENT, generateIdNumber())),
                new FileNotFoundException(String.format(NARRATIVE_EXCEPTION_FILE_NOT_FOUND, generateIdNumber())),
                new AccessDeniedException(String.format(NARRATIVE_EXCEPTION_ACCESS_DENIED, generateIdNumber())),
                new MalformedURLException(String.format(NARRATIVE_EXCEPTION_MALFORMED_URL, generateIdNumber()))
        };
    }

    private int getRandomIntFromRange() {
        return new Random().nextInt((MAX_RANGE - MIN_RANGE) + 1) + MIN_RANGE;
    }

    protected String generateName() {
        return faker.name().fullName();
    }

    protected String generateAddress() {
        return faker.address().fullAddress();
    }

    protected String generateIdNumber() {
        return faker.idNumber().validSvSeSsn();
    }

    protected String generatePhoneNumber() {
        return faker.phoneNumber().phoneNumber();
    }

    protected String generateIBAN() {
        return faker.finance().iban();
    }

    protected String generatePrice() {
        return faker.commerce().price();
    }

}


