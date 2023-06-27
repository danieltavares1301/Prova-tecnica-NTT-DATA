public class AccountTriggerHandler {
    public static void validaNumeroCliente(){
        for(Account acc : (List<Account>)Trigger.New){
            if(acc.Type=='CPF'){
                String cpf = acc.AccountNumber.replace('.','').replace('-','');
                Boolean isValidCPF = Utils.validaCPF(cpf);
                if(!isValidCPF){
                    acc.addError('Número do cliente é inválido');
                }else{
                    acc.AccountNumber = Utils.formataCPF(cpf); // adiciona o cpf formatado
                }
            }else if(acc.Type=='CNPJ'){ // "else if" é usado supondo que tenha mais tipos de contas além de CPF e CNPJ
                String cnpj = acc.AccountNumber.replace('.','').replace('-','').replace('/', '');
                Boolean isValidCNPJ = Utils.validaCNPJ(cnpj); 
                if(!isValidCNPJ){
                    acc.addError('Número do cliente é inválido');
                }else{
                    acc.AccountNumber = Utils.formataCNPJ(cnpj); // adiciona o cnpj formatado
                }
            }
        }
    }
    
    public static void verificaTipoDeRegistro(){
        Id recordTypeIdParceiro = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parceiro').getRecordTypeId();
        Id recordTypeIdConsumidorFinal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumidor final').getRecordTypeId();
        
        List<Opportunity> newOpps = new List<Opportunity>();
        List<Task> newTasks = new List<Task>();
        
        for(Account acc : (List<Account>)Trigger.New){            
            if(acc.RecordTypeId==recordTypeIdParceiro){
                newOpps.add(new Opportunity(Name=acc.Name+' - opp Parceiro', AccountId=acc.Id, 
                                            CloseDate=System.Today().addDays(30), StageName='Qualification'));
                
            }else if(acc.RecordTypeId==recordTypeIdConsumidorFinal){
                newTasks.add(new Task(Subject='Consumidor Final', WhatId=acc.Id, Status='Not Started', Priority='Normal'));
            }
        }
        
        if(newOpps.size()>0){
            insert newOpps;
        }
        
        if(newTasks.size()>0){
            insert newTasks;
        }
    }
}