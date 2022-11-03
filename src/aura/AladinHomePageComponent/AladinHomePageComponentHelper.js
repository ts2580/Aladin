({
	getBranchBook : function(component, event, helper){
        var action = component.get("c.getBranch");

        /*action.setParams({
            "recordId" : component.get("v.recordId")
        })*/

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){

                var BranchMap = response.getReturnValue();

                var TotalBranchDiv = parseInt(Object.keys(BranchMap).length/10);

                for(var i = 0; i < TotalBranchDiv+1; i++){
                    var BranchDIV = document.createElement('div');
                    BranchDIV.classList.add('Branch_' + i);
                    BranchDIV.style.display = 'flex';
                    BranchDIV.style.justifyContent = 'center';
                    document.querySelector(".Branch").appendChild(BranchDIV);
                }

                var i = 0;
                var t = 0;
                for (var key in BranchMap) {
                    var URL = BranchMap[key][0];
                    var TotalBookValue = BranchMap[key][1];
                    var BranchId = BranchMap[key][2];
                    var BranchNameDIV = document.createElement('a');
                    BranchNameDIV.classList.add('Branch-Detail');
                    BranchNameDIV.innerHTML  = key + '<br>' + parseInt(TotalBookValue).toLocaleString('ko-KR') + '원';
                    BranchNameDIV.href = URL+ '/lightning/r/Branch__c/' + BranchId + '/view';
                    BranchNameDIV.target = "_blank";
                    document.querySelector('.Branch_' + i).appendChild(BranchNameDIV);

                    t++;

                    if(t%10 == 0){
                        i++;
                    }

                }

            }
        });

        $A.enqueueAction(action);
    },

    makeBranchBooksDiv : function(component, event, helper){

        alert('Hello World');

    }
})