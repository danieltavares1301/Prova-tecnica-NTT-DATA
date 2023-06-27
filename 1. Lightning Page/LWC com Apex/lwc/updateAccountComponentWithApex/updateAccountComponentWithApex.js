import { LightningElement, api, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import updateAccountWithComponent from '@salesforce/apex/UpdateAccount.updateAccountWithComponent';



export default class UpdateAccountComponentWithApex extends LightningElement {
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
        const accountType = this.CPF ? 'CPF' : 'CNPJ';

        if ((this.CPF || this.CNPJ) && this.accountNumber && this.accountName) {
            updateAccountWithComponent({accountId: this.recordId, accountName: this.accountName, accountNumber: this.accountNumber, accountType: accountType})
                .then(() => {
                    alert('Conta atualizada com sucesso!');
                })
                .catch(error => {
                    // tratamento da messagem de erro que vem com muitas informações
                    const errorMessage = error.body?.message.includes('Número do cliente é inválido') ? 'Número do cliente é inválido' : 'Não foi possível concluir a atualização. Por favor, tente novamente!';
                    alert(errorMessage);
                    
                }); 
        }else{
            alert('Preencha todos os campos para concluir a atualização!')
        }
    }
}