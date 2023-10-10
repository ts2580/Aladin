/**
 * Created by 한성진 on 2023-09-27.
 */

global class SortCompare implements Comparable {

    public BranchBookExt__x bbe;

    // Constructor
    public SortCompare(BranchBookExt__x op) {
        bbe = op;
    }

    // Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        SortCompare compareTobbe = (SortCompare)compareTo;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (bbe.Name__c > compareTobbe.bbe.Name__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (bbe.Name__c < compareTobbe.bbe.Name__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }

        return returnValue;
    }

}