import { LightningElement, api, wire, track } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getOrderProducts from '@salesforce/apex/OrderController.getOrderProducts';

import PRODUCT_ADDED_MC from '@salesforce/messageChannel/ProductAdded__c';
import {subscribe, MessageContext} from 'lightning/messageService'

export default class OrderProducts extends LightningElement {

    columns = [
        {
            label: 'Name',
            fieldName: 'name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Unit Price',
            fieldName: 'unitPrice',
            sortable: true,
            type: 'currency',
            typeAttributes: { currencyCode: 'EUR'}
        },
        {
            label: 'Quantity',
            fieldName: 'quantity',
            sortable: true,
            type: 'number'
        },
        {
            label: 'Total Price',
            fieldName: 'totalPrice',
            sortable: true,
            type: 'currency',
            typeAttributes: { currencyCode: 'EUR'}
        } 
    ];
    @track orderProducts = [];

    @track wiredOrderProducts = [];

    @api recordId;

    connectedCallback(){
        this.isLoading = true;
        this.subscribeProductMC();
    }   

    @wire(getOrderProducts, { orderId: '$recordId' })
    orderProductList(result) {
        // Saving the result in a variable to use later in the refreshApex function
        this.wiredOrderProducts = result;
        if (result.data) {
            this.orderProducts = result.data;
        } else if (result.error) {
            this.showToastMessage('error', 'Error retrieving the products.', result.error.body.message);
        }
        this.isLoading = false;
    }

    @wire(MessageContext)
    messageContext;

    subscriptionProduct = null;
    subscribeProductMC() {
        // Subscribe to the message channel to know when a product is added to the order. After the addition we call refresApex
        if (!this.subscriptionProduct) {
            this.subscriptionProduct = subscribe(
                                        this.messageContext,
                                        PRODUCT_ADDED_MC,
                                        (message) => { refreshApex(this.wiredOrderProducts) }
                                );
        }
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