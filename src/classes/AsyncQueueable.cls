public with sharing class AsyncQueueable implements Queueable {

    Integer cycle;

    private final List<Contact> listContact;

    public AsyncQueueable(List<Contact> listContact, Integer cycle){
        this.listContact = listContact;
        this.cycle = cycle;
    }

    public void execute(QueueableContext context) {

        for (Contact obj : listContact) {
            obj.phone = cycle + ' 번째 배치 테스트';
            obj.Fax = 'Queueable 테스트';
        }

        update listContact;

        cycle += 1;

        List<Contact> listContact = [
                select Id
                from Contact
                where Fax != 'Queueable 테스트'
                order by Name
                limit 50
        ];

        if(listContact.size() > 0){
            System.enqueueJob(new AsyncQueueable(listContact,cycle));
        }

    }
}