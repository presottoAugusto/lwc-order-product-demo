public with sharing class OrderService {
    public static void activateOrder(Order ord) {
        ord.Status = 'Activated';
        update ord;
    }
}