import { LightningElement, api, wire, track } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { publish, subscribe, MessageContext } from 'lightning/messageService';

import getAvailableProducts from '@salesforce/apex/OrderController.getAvailableProducts';
import addProductToOrder from '@salesforce/apex/OrderController.addProductToOrder';

import PRICEBOOK_ID_FIELD from '@salesforce/schema/Order.Pricebook2Id';
import STATUS_FIELD from '@salesforce/schema/Order.Status';

import PRODUCT_ADDED_MC from '@salesforce/messageChannel/ProductAdded__c';
import ORDER_CONFIRMED_MC from '@salesforce/messageChannel/OrderConfirmed__c';

const ORDER_FIELDS = [ PRICEBOOK_ID_FIELD, STATUS_FIELD ]; 
const STATUS_ACTIVATED = 'Activated';

const COLUMNS = [
    { label: 'Name', fieldName: 'name', type: 'text', sortable: true },
    { label: 'List Price', fieldName: 'unitPrice', sortable: true, type: 'currency', typeAttributes: { currencyCode: 'EUR' } },
    { type: "button",
                        fixedWidth: 150,
                        typeAttributes: {
                            label: 'Add to Order',
                            title: 'Add Product',
                            name: 'addProduct',
                            value: 'addProduct',
                            variant: 'brand',
                            class: 'add-to-order',
                            disabled: { fieldName: 'disabled' }
                        }}
];

export default class AvailableProducts extends LightningElement {
    columns;

    @api recordId;

    @track data = [];
    isLoading = false;
    offSetCount = 0;
    targetDatatable = null;
    @track btnDisabled = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.isLoading = true;
        this.subscribeOrderMC();
    }    

    wiredOrder = [];
    order;
    isOrderActivated;

    @wire(getRecord, { recordId: '$recordId', fields: ORDER_FIELDS })
    wiredOrder(result) {
        if (result.data) {
            this.wiredOrder = result;
            this.order = result.data;
            // Here the value can be set on the first load of the page and after we call refreshApex from the Message Channel subscription
            this.isOrderActivated = this.order.fields.Status.value === STATUS_ACTIVATED;
            this.columns = COLUMNS;
            this.getProducts();
        } else if (result.error) {
            this.showToastMessage('error', 'Unable to retrieve Order.', error.body.message);
        }
    }
    
    getProducts() {
        getAvailableProducts({pricebookId: this.order.fields.Pricebook2Id.value, offset: this.offSetCount})
        .then(result => {
            if (!result.length) {
                this.targetDatatable.enableInfiniteLoading = false;
            }
            this.data = this.data.concat(result);
            if (this.isOrderActivated) {
                this.data.forEach((item) => {
                    item.disabled = true;
                });
            }
            if (this.targetDatatable) {
                this.targetDatatable.isLoading = false;
            }   
        })
        .catch(error => {
            this.showToastMessage('error', 'Error retrieving the products.', error.body.message);
        }).finally(() => {
            this.isLoading = false;
        });
    }
    
    //called by the onRowAction datable's event
    addProduct(event) {  
        let productToAdd =  Object.assign({}, event.detail.row);
        this.isLoading = true;
        addProductToOrder({orderId: this.recordId, pricebookEntryId: productToAdd.pricebookEntryId, unitPrice: productToAdd.unitPrice}).then(() => {
                this.showToastMessage('success', 'Success', 'Product added to order successfully!');
                //After the successfull addition of the product we publish to the Message Channel so other components will be notified
                publish(this.messageContext, PRODUCT_ADDED_MC, {});
        })
        .catch(error => {
            this.showToastMessage('error', 'Unable to add Product to Order', error.body.message);
        }).finally(() => {
            this.isLoading = false;
        });
                  
    }  

    // Event to handle onloadmore on lightning datatable
    loadMoreProducts(event) {
        event.preventDefault();

        //Add more to the offset so Apex can retrieve more records
        this.offSetCount = this.offSetCount + 15;
        // Set the spinner at the end of the table
        event.target.isLoading = true;        
        this.targetDatatable = event.target;

        this.getProducts();
    }

    //Subscribe to Message Channel to know when the order is confirmed and Activated
    // the refreshApex function will update the order record
    subscriptionOrder = null
    subscribeOrderMC() {
        if (!this.subscriptionOrder) {
            this.subscriptionOrder = subscribe(
                                        this.messageContext,
                                        ORDER_CONFIRMED_MC,
                                        (message) => { refreshApex(this.wiredOrder); }
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