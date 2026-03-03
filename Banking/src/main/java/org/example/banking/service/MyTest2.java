package org.example.banking.service;

import java.util.Arrays;

public class MyTest2 {
    public static void main(String[] args) {
//        Write a java program to get 3rd highest salary in java 8 program.

        emps.stream()
                .sorted((e1,e2)->DobleCompare(e1.getSalary(),e2.getSalary()))
                .skip(2)
                .findFirst()
                .orElse(null);


    }
}
