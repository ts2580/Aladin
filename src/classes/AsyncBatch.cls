/**
 * Created by trsty on 24. 9. 3..
 */

public with sharing class AsyncBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('Select Id From Contact order by name');
    }

    Integer cycle = 1;

    public void execute(Database.BatchableContext context, List<Contact> records) {

        for (Contact obj : records) {
            obj.phone = cycle + ' 번째 배치 테스트';
            obj.fax = '배치 테스트';
        }

        update records;

        cycle += 1;
    }

    public void finish(Database.BatchableContext context) {
        System.debug('끝');
    }

    
}