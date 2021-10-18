import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import confirmOrder  from '@salesforce/apex/ConfirmOrder.confirm';

import STATUS_FIELD from '@salesforce/schema/Order.Status';

import ORDER_CONFIRMED_MC from '@salesforce/messageChannel/OrderConfirmed__c';

export default class OrderOptions extends LightningElement {
    @api recordId;

    order;
    btnDisabled = true;
    isLoading = false;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD]})
    wiredOrder( { error, data }) {
        if (data) {
            this.order = data;
            // Disable the button if order is Activated
            this.btnDisabled = (this.order.fields.Status.value === 'Activated');
        } else  if(error) {
            this.showToastMessage('error', 'Unable to retrieve Order', error.message);
        }
    }

    @wire(MessageContext)
    messageContext;

    // Handler for the button click
    handleConfirmOrder() {
        this.isLoading = true;
        confirmOrder({orderId: this.recordId})
        .then( result => {
            publish(this.messageContext, ORDER_CONFIRMED_MC, {});
            this.btnDisabled = true;
            this.showToastMessage('success', 'Order Confirmed', 'Your Order was confirmed!');
        })
        .catch( error => {
            this.showToastMessage('error', 'Unable to confirm Order', error.message);
        })
        .finally(() => {
            this.isLoading = false;
        })
    }

    showToastMessage(variant, title, message) {
        const event = new ShowToastEvent({
            "title": title,
            "variant": variant,
            "message": message
        });
        this.dispatchEvent(event);
    }
}