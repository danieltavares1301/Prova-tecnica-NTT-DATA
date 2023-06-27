import { LightningElement, api, wire} from 'lwc';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import ACCOUNTNUMBER_FIELD from '@salesforce/schema/Account.AccountNumber';



export default class UpdateAccountComponent extends LightningElement {
    @api recordId;
    
    CPF;
    CNPJ;
    accountNumber;
    accountName;
    record;

    // campo Type foi o único registro pego, pois, ao abrir a página, vi como necessário o checkbox correto já estar marcado com o valor atual do registro
    @wire(getRecord, {recordId: '$recordId', fields: ['Account.Type']})
    wiredAccount({error, data}){
        if(data){
            this.record = data;
            this.CPF = this.record.fields.Type.value === 'CPF';
            this.CNPJ = this.record.fields.Type.value === 'CNPJ';
        }
    };

    

    handleCheckboxChange(event) {
        const checkboxValue = event.target.checked;
        // lógica do checkbox leva em consideração valor atual e anterior
        if (event.target.label === 'CPF') {
            if(this.CPF===false && checkboxValue==true){
                this.CPF = checkboxValue;
                this.CNPJ = !checkboxValue;
            }else{
                this.CPF = checkboxValue;
            }
        } else if (event.target.label === 'CNPJ') {
            if(this.CNPJ===false && checkboxValue==true){
                this.CPF = !checkboxValue;
                this.CNPJ = checkboxValue;
            }else{
                this.CNPJ = checkboxValue;
            }
        }
    }

    handleAccountNumberChange(event){
        this.accountNumber = event.target.value;
    }

    handleAccountNameChange(event){
        this.accountName = event.target.value;
    }

    handleSave() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[NAME_FIELD.fieldApiName] = this.accountName;
        fields[TYPE_FIELD.fieldApiName] = this.CPF ? 'CPF' : 'CNPJ';
        fields[ACCOUNTNUMBER_FIELD.fieldApiName] = this.accountNumber;
        const recordInput = {fields};

        if ((this.CPF || this.CNPJ) && this.accountNumber && this.accountName) {
            updateRecord(recordInput)
                .then(() => {
                    alert('Conta atualizada com sucesso!');
                })
                .catch(error => {
                    // mesagem de erro já vem formatada para o usuário
                    alert(error.body.message);
                });
        }else{
            alert('Preencha todos os campos para concluir a atualização!')
        }
    }
}