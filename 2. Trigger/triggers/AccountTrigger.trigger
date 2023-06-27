trigger AccountTrigger on Account (before insert, before update, after insert) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        AccountTriggerHandler.validaNumeroCliente();
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        AccountTriggerHandler.verificaTipoDeRegistro();
    }
}