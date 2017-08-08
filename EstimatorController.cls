public with sharing class EstimatorController {
        
        /*-------------Variables----------------------*/
        @TestVisible public String productId {get; set;}
        @TestVisible public Product2 mySelectedProduct {get; set;}
        public String patientName {get; set;}
        public Decimal currentPrice {get; set;}
        public Decimal totalPrice {get; set;}
        public String procBox {get; set;} //Holds the typed procedure
        public Decimal amtBox {get; set;} //Holds the typed price
        public List<Product2> productList {get; set;}
        public Map<String, Decimal> inputProcedures {get; set;}
        public String todayDate {get; set;}
         
        public EstimatorController() {
        //Product Ids are set to the "No Selected Product" product in the database.  findProduct functions called to make sure no vars are null
            //ProductId = '01tE0000007GDIK';  //Use 01tE0000007GDIK for production, 01te0000001705G for sandbox
            productList = new List<Product2>();
            inputProcedures = new Map<String, Decimal>();
            this.todayDate = Date.today().format();

            //findProduct();
        }
        
        //Retrieve a list of Products we have created in Salesforce
        public List<SelectOption> getProducts () {
                List<Product2> myProducts = [SELECT Name, Id, (Select UnitPrice From PricebookEntries) from Product2 ORDER BY Name ASC];
                List<SelectOption> options = new List<SelectOption>();
                //options.add (new SelectOption ('', 'Select your option'));
                for (Product2 p : myProducts) {
                    options.add(new SelectOption (p.Id, p.Name));
                }
                return options;
        }
        
        //Displays selected product price in field on page
        public PageReference findProduct() {
            //productPrice = productMap.get(productId);
            mySelectedProduct = [Select Id, Name, CreatedDate, (Select UnitPrice from PricebookEntries) from Product2 WHERE Id = :ProductId];
            //Product2 msp = [Select Id, Name, CreatedDate, (Select UnitPrice from PricebookEntries) from Product2 WHERE Id = '01te0000001705G' ];
            currentPrice = mySelectedProduct.PriceBookEntries[0].UnitPrice;
           return null;
        } 
        
        public PageReference addProduct() {
            //if (ProductId != '01te0000001705G') {
            //    productList.add (mySelectedProduct);
            //}
            
            try {
                productList.add(mySelectedProduct);
            } catch (NullPointerException  npe) {
                System.debug('You need to select a product first!');
            } 
            return null;
        }
        
        public PageReference addTypedInfo() {
           if (procBox != null) {
               inputProcedures.put (procBox, amtBox);
           }
           return null;
        }
        
        public PageReference calculateTotal () { 
            Decimal sum = 0.00;
            for (Product2  p : this.productList) {
                //Product2 pp = [SELECT Id, (SELECT UnitPrice from PricebookEntries) FROM Product2 WHERE Id = :p.Id];
                try {
                    sum += p.PriceBookEntries[0].UnitPrice;
                } catch (NullPointerException npe) {
                    System.debug ('Theres a null spot in your array of products.');
                }    
            }
            
            List<Decimal> otherValues = this.inputProcedures.values();
            if (otherValues.size() > 0) {
                for (Decimal d : otherValues) {  //Get a list of values in other Procedures and add them to sum
                    sum +=d;
                }
            }
            this.totalPrice = sum; 
            return null;
        }
        
        public PageReference createEstimatePDF () {
            PageReference myEstimate = Page.estimatorPDF;
            return myEstimate;
        }
}