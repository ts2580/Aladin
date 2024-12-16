public with sharing class AsyncCursor implements Queueable {

    private Integer cycle;

    private Database.Cursor locator;

    // 시작점
    private Integer position;

    // 처리 단위
    private integer unit = 80;

    public AsyncCursor(Database.Cursor locator){
        this.locator = locator;

        cycle = 1;

        position = 0;
    }

    public void execute(QueueableContext context) {

        try{
            List<Contact> scope = locator.fetch(position,unit);

            for (Contact c : scope) {
                c.Phone = cycle + ' 번째 싸이클';
                c.Fax = 'Cursor 테스트2';
            }

            update scope;

            position += unit;
        }catch (Exception e){
            System.debug('Error!!! : ' + e.getMessage());

            if((position + unit) > locator.getNumRecords()){
                System.debug('마지막 싸이클');
                unit = locator.getNumRecords() - position;
            }
        }

        cycle += 1;

        System.debug('unit : ' + unit);
        System.debug('position : ' + position);

        // locator.getNumRecords() : 총 갯수
        if(position < locator.getNumRecords()){
            System.enqueueJob(this);
        }

    }
}