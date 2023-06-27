@isTest
public class AccountTriggerHandlerTest {
    @isTest
    static void validaNumeroClienteSuccess(){
        List<Account> accList = new List<Account>();
        
        for(Integer i=1; i<=5;i++){
            accList.add(new Account(Name='Conta Teste CPF '+i, Type='CPF', AccountNumber='13884183397'));
            accList.add(new Account(Name='Conta Teste CNPJ '+i, Type='CNPJ', AccountNumber='41484334000165'));
        }
        
        test.startTest();
        insert accList;
        test.stopTest();
        
        //verifica se todos os registros foram acrescentados com sucesso
        System.assertEquals(5, [SELECT count() FROM Account WHERE Type='CPF']); 
        System.assertEquals(5, [SELECT count() FROM Account WHERE Type='CNPJ']);
    }
    
    @isTest
    static void validaNumeroClienteFail(){
        List<Account> accList = new List<Account>();
        
        for(Integer i=1; i<=5;i++){
            accList.add(new Account(Name='Conta Teste CPF 1', Type='CPF', AccountNumber='11111111111'));
            accList.add(new Account(Name='Conta Teste CNPJ 1', Type='CNPJ', AccountNumber='12345678901234'));
        }
        
        String errorMessage = '';   
        
        try{
            test.startTest();
            insert accList;
            test.stopTest();
        }catch(exception e){
            errorMessage = e.getMessage();
        }
        
        System.assert(errorMessage.contains('Número do cliente é inválido')); 
        //verifica se nenhum registro foi acrescentado
        System.assertEquals(0, [SELECT count() FROM Account WHERE Type='CPF']); 
        System.assertEquals(0, [SELECT count() FROM Account WHERE Type='CNPJ']);
    }
    
    @isTest
    static void verificaTipoDeRegistroParceiro(){
        Id recordTypeIdParceiro = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parceiro').getRecordTypeId();
        Set<Id> accIds = new Set<Id>();
		List<Account> accList = new List<Account>(); 
        Set<String> nameOppList = new Set<String>();
        
        for(Integer i=1; i<=5;i++){
            accList.add(new Account(Name='Conta Teste Parceiro '+i, RecordTypeId=recordTypeIdParceiro));
            nameOppList.add('Conta Teste Parceiro '+i+' - opp Parceiro'); // adicionando os nomes em uma lista separada para depois verificar se existem oportunidade com os nomes das contas inclusos
        }
                
        test.startTest();
        insert accList;
        test.stopTest();       
        
        for(Account acc : accList){
            accIds.add(acc.Id);
        }
        
        
        System.assertEquals(5, [SELECT count() FROM Opportunity WHERE StageName='Qualification' AND Name IN :nameOppList AND AccountId IN :accIds]);
    }
    
    @isTest
    static void verificaTipoDeRegistroConsumidorFinal(){
        Id recordTypeIdConsumidorFinal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumidor final').getRecordTypeId();
        Set<Id> accIds = new Set<Id>();
		List<Account> accList = new List<Account>(); 
        
        for(Integer i=1; i<=5;i++){
            accList.add(new Account(Name='Conta Teste Consumidor Final '+i, RecordTypeId=recordTypeIdConsumidorFinal));
        }
                
        test.startTest();
        insert accList;
        test.stopTest();  
        
        for(Account acc : accList){
            accIds.add(acc.Id);
        }
        
        System.assertEquals(5, [SELECT count() FROM Task WHERE Subject='Consumidor Final' AND WhatId IN :accIds]);
    }
}