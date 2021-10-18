import { createElement } from 'lwc';
import OrderOptions from 'c/OrderOptions';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';




describe('c-OrderOptions', () => {

    it('renders the error panel when the Apex method returns an error', () => {

        // Create initial element
        const element = createElement('c-OrderOptions', {
            is: OrderOptions
        });
        document.body.appendChild(element);

       const handler = jest.fn();
    // Add event listener to catch toast event
       element.addEventListener(ShowToastEventName, handler);

       const buttonEl = element.shadowRoot.querySelector('lightning-button');
        buttonEl.click();


        const div = element.shadowRoot.querySelector('div');
        return Promise.resolve().then(() => {
        expect(div.textContent).toBe('errorMessage');
        expect(handler).toHaveBeenCalled();
        });
    });


});