global class AccountCleaningBatch implements Database.Batchable<sObject>,Schedulable {  
    global Database.QueryLocator start(Database.BatchableContext bc){
        Set<Id> accountIds = new Set<Id>(); 
        
        List<Task> tasks = [SELECT WhatId FROM Task WHERE What.Type = 'Account' AND CreatedDate >= :Date.today().addDays(-90)];
        
        for (Task task : tasks) {
            accountIds.add(task.WhatId);
        }
        
        List<Opportunity> opps = [SELECT AccountId FROM Opportunity WHERE (StageName = 'Closed Won' AND CloseDate >= :Date.today().addDays(-120)) OR StageName = 'Negotiation'];
        
        for (Opportunity opp : opps) {
            accountIds.add(opp.AccountId);
        }
        
        // Apenas contas que:
        //  - não estejam na lista de contas com tarefas dos últimos 90 dias
        //  - não estejam na lista de contas com oportunidades ganhas nos últimos 120 dias ou com oportunidades em negociação
        //  - não está inativa no momento
        return Database.getQueryLocator([SELECT Inativa__c FROM Account WHERE Id NOT IN :accountIds AND Inativa__c=false]);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> inactiveAccounts){
        for (Account acc : inactiveAccounts) {
            acc.Inativa__c = true;
        }
        
        if (inactiveAccounts.size()>0) {
            update inactiveAccounts;
        }
    }
    
    global void finish(Database.BatchableContext bc){}
    
    // esta função pode se localizar aqui ou em outra classe que seja feita apenas para executar o batch.  
    global void execute(SchedulableContext ctx) {
        AccountCleaningBatch acb = new AccountCleaningBatch();
		database.executebatch(acb, 200);
    }
    
    // Para rodar o batch basta executar o seguinte código no developer console:
    // System.schedule('Account Cleanning Batch Scheduler', '0 0 0,6,12,18 ? * MON-FRI', new AccountCleaningBatch()); // roda às 0h, 6h, 12h e 18h, de segunda à sexta
}