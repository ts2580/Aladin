public class TempController {
	
    public List<Book__c> Books {get; set;}


    // 필드셋 연습용
    public TempController(ApexPages.StandardController stdController){
    	this.Books = getBooks();
    }
    
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Book__c.fieldSets.fieldSetSample.getFields();
    }
    
    public List<Book__c> getBooks(){
        String query = 'SELECT ';

		for(Schema.FieldSetMember field : this.getFields()) {

			query += field.getFieldPath() + ', ';

		}
        
		query += 'Type__c FROM Book__c where Type__c =' + '\'교양\'';
        
        System.debug(query);
		return Database.query(query);
    }

    public static void doBatch_1(){
        List<BranchBook__c> BranchBook= [SELECT Id FROM BranchBook__c];

        delete BranchBook;

        Integer startNum = 1;
        Integer endNum = 50;

        for(Integer i = 2; i < 30; i++){
            IF_GetDropshippingUsedBook.getBookListInfo(startNum, endNum);
            startNum = endNum;
            endNum = 50*i;
        }
    }

    public static void doBatch_2(){

        String StringPrice = null;
        String FormattingPrice = null;
        String FormattedPrice = null;

        List<AggregateResult> AggregateBranchName = [SELECT Branch__c, SUM(f_MinPrice__c) TotalPrice
        FROM BranchBook__c
        GROUP BY Branch__c
        ORDER BY SUM(f_MinPrice__c) DESC];

        Map<Id, String> MapBranch = new Map<Id, String>();

        for(AggregateResult ABN : AggregateBranchName){
            MapBranch.put(String.valueOf(ABN.get('Branch__c')), String.valueOf(ABN.get('TotalPrice')));
        }

        List<Branch__c> ListBranch = [SELECT Id, Name, TotalPrice__c FROM Branch__c];

        for(Branch__c B : ListBranch){

            StringPrice = MapBranch.get(B.Id);
            FormattingPrice = ( Decimal.valueOf(StringPrice.trim()==''?'0':StringPrice).setScale(2)).format();
            FormattedPrice = FormattingPrice.substring(0,FormattingPrice.length())+'원';
            B.TotalPrice__c = FormattedPrice;
        }

        update ListBranch;

    }
    
    
    
}