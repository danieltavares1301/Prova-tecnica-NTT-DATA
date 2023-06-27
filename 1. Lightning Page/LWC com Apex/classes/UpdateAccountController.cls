public with sharing class UpdateAccountController {
    @AuraEnabled
    public static void updateAccountWithComponent(String accountId, String accountName, String accountNumber, String accountType){
        if(accountId!=null && accountName!=null && accountNumber!=null && accountType!=null){
            try {
                Account updatedAcc = new Account();
                updatedAcc.Id = accountId;
                updatedAcc.Name = accountName;
                updatedAcc.AccountNumber = accountNumber;
                updatedAcc.Type = accountType;

                update updatedAcc;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
    }
}